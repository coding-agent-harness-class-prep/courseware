package com.example.orders.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.example.orders.catalog.InMemoryProductCatalog;
import com.example.orders.model.CustomerTier;
import com.example.orders.model.Order;
import com.example.orders.model.OrderStatus;
import com.example.orders.pricing.DiscountPolicy;
import com.example.orders.pricing.TaxCalculator;
import com.example.orders.validation.OrderValidator;
import com.example.orders.validation.ValidationCodes;
import com.example.orders.validation.ValidationError;

class OrderServiceTest {

    private final InMemoryOrderRepository repository = new InMemoryOrderRepository();
    private final OrderService service;

    OrderServiceTest() {
        var catalog = new InMemoryProductCatalog();
        var tax = new TaxCalculator();
        service = new OrderService(repository, catalog, new OrderValidator(catalog, tax),
                new DiscountPolicy(), tax, Clock.systemUTC());
    }

    @Test
    void create_validRequest_savesPendingOrderWithCatalogPrices() {
        // Oregon has no sales tax and the order is too small for any discount.
        var request = new CreateOrderRequest("C-1001", CustomerTier.STANDARD, "OR",
                List.of(new OrderLineRequest("KB-MECH", 2), new OrderLineRequest("MS-WL", 1)), null);

        CreateOrderOutcome outcome = service.create(request);

        assertThat(outcome.succeeded()).isTrue();
        Order order = outcome.order().orElseThrow();
        assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING);
        assertThat(order.getLines().getFirst().unitPrice()).isEqualByComparingTo("89.00");
        assertThat(order.getPrice().subtotal()).isEqualByComparingTo("202.50");
        assertThat(order.getPrice().total()).isEqualByComparingTo("202.50");
        assertThat(repository.find(order.getId())).containsSame(order);
    }

    @Test
    void create_invalidRequest_returnsErrorsAndSavesNothing() {
        var request = new CreateOrderRequest("", CustomerTier.STANDARD, "OR", List.of(), null);

        CreateOrderOutcome outcome = service.create(request);

        assertThat(outcome.succeeded()).isFalse();
        assertThat(outcome.validation().errors())
                .extracting(ValidationError::code).contains(ValidationCodes.CUSTOMER_REQUIRED);
        assertThat(repository.all()).isEmpty();
    }

    @Test
    void list_withStatus_returnsOnlyMatchingOrders() {
        Order first = service.create(new CreateOrderRequest("C-1", CustomerTier.STANDARD, "OR",
                List.of(new OrderLineRequest("MS-WL", 1)), null)).order().orElseThrow();
        service.create(new CreateOrderRequest("C-2", CustomerTier.STANDARD, "OR",
                List.of(new OrderLineRequest("MS-WL", 1)), null));
        first.setStatus(OrderStatus.SHIPPED);

        assertThat(service.list(OrderStatus.SHIPPED)).extracting(Order::getId).containsExactly(first.getId());
    }
}
