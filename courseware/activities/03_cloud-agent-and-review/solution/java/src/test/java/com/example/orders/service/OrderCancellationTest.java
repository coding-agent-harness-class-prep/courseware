package com.example.orders.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;

import com.example.orders.catalog.InMemoryProductCatalog;
import com.example.orders.model.CustomerTier;
import com.example.orders.model.Order;
import com.example.orders.model.OrderStatus;
import com.example.orders.pricing.DiscountPolicy;
import com.example.orders.pricing.TaxCalculator;
import com.example.orders.validation.OrderValidator;

class OrderCancellationTest {

    private final OrderService service;

    OrderCancellationTest() {
        var catalog = new InMemoryProductCatalog();
        var tax = new TaxCalculator();
        service = new OrderService(new InMemoryOrderRepository(), catalog, new OrderValidator(catalog, tax),
                new DiscountPolicy(), tax, Clock.systemUTC());
    }

    private Order placeOrder() {
        return service.create(new CreateOrderRequest("C-1001", CustomerTier.STANDARD, "OR",
                List.of(new OrderLineRequest("MS-WL", 1)), null)).order().orElseThrow();
    }

    @Test
    void cancel_pendingOrder_marksItCanceled() {
        Order order = placeOrder();

        assertThat(service.cancel(order.getId())).isEqualTo(CancelOutcome.CANCELED);
        assertThat(service.find(order.getId()).orElseThrow().getStatus()).isEqualTo(OrderStatus.CANCELED);
    }

    @Test
    void cancel_unknownOrder_returnsNotFound() {
        assertThat(service.cancel(UUID.randomUUID())).isEqualTo(CancelOutcome.NOT_FOUND);
    }

    @ParameterizedTest
    @EnumSource(value = OrderStatus.class, names = {"PAID", "SHIPPED", "CANCELED"})
    void cancel_orderNoLongerPending_returnsNotPendingAndLeavesStatus(OrderStatus status) {
        Order order = placeOrder();
        order.setStatus(status);

        assertThat(service.cancel(order.getId())).isEqualTo(CancelOutcome.NOT_PENDING);
        assertThat(order.getStatus()).isEqualTo(status);
    }
}
