package com.example.orders.service;

import java.math.BigDecimal;
import java.time.Clock;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.orders.catalog.ProductCatalog;
import com.example.orders.model.CustomerTier;
import com.example.orders.model.Order;
import com.example.orders.model.OrderLine;
import com.example.orders.model.OrderStatus;
import com.example.orders.pricing.DiscountBreakdown;
import com.example.orders.pricing.DiscountPolicy;
import com.example.orders.pricing.Money;
import com.example.orders.pricing.PriceSummary;
import com.example.orders.pricing.TaxCalculator;
import com.example.orders.validation.OrderValidator;
import com.example.orders.validation.ValidationResult;

@Service
public class OrderService {

    private final OrderRepository orders;
    private final ProductCatalog catalog;
    private final OrderValidator validator;
    private final DiscountPolicy discountPolicy;
    private final TaxCalculator taxCalculator;
    private final Clock clock;

    public OrderService(OrderRepository orders, ProductCatalog catalog, OrderValidator validator,
            DiscountPolicy discountPolicy, TaxCalculator taxCalculator, Clock clock) {
        this.orders = orders;
        this.catalog = catalog;
        this.validator = validator;
        this.discountPolicy = discountPolicy;
        this.taxCalculator = taxCalculator;
        this.clock = clock;
    }

    public CreateOrderOutcome create(CreateOrderRequest request) {
        ValidationResult validation = validator.validate(request);
        if (!validation.isValid()) {
            return new CreateOrderOutcome(Optional.empty(), validation);
        }

        List<OrderLine> lines = request.lines().stream()
                .map(l -> new OrderLine(l.sku(), l.quantity(), catalog.find(l.sku()).orElseThrow().unitPrice()))
                .toList();

        CustomerTier tier = request.customerTier() == null ? CustomerTier.STANDARD : request.customerTier();

        Order order = new Order(
                UUID.randomUUID(),
                request.customerId(),
                tier,
                request.region().toUpperCase(Locale.ROOT),
                lines,
                request.couponCode(),
                price(lines, tier, request.region(), request.couponCode()),
                clock.instant());

        orders.save(order);
        return new CreateOrderOutcome(Optional.of(order), validation);
    }

    public Optional<Order> find(UUID id) {
        return orders.find(id);
    }

    public List<Order> list(OrderStatus status) {
        return orders.all().stream()
                .filter(o -> status == null || o.getStatus() == status)
                .toList();
    }

    /** Cancels an order. Only an order that is still pending can be canceled. */
    public CancelOutcome cancel(UUID id) {
        Optional<Order> found = orders.find(id);
        if (found.isEmpty()) {
            return CancelOutcome.NOT_FOUND;
        }

        Order order = found.get();
        if (order.getStatus() != OrderStatus.PENDING) {
            return CancelOutcome.NOT_PENDING;
        }

        order.setStatus(OrderStatus.CANCELED);
        orders.save(order);
        return CancelOutcome.CANCELED;
    }

    private PriceSummary price(List<OrderLine> lines, CustomerTier tier, String region, String couponCode) {
        BigDecimal subtotal = lines.stream().map(OrderLine::lineTotal).reduce(Money.ZERO, BigDecimal::add);
        DiscountBreakdown discounts = discountPolicy.calculate(lines, tier, couponCode);
        BigDecimal taxable = subtotal.subtract(discounts.total());
        BigDecimal tax = taxCalculator.calculate(taxable, region);
        return new PriceSummary(subtotal, discounts, tax, taxable.add(tax));
    }
}
