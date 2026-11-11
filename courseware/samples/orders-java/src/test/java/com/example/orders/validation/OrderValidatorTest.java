package com.example.orders.validation;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import com.example.orders.catalog.InMemoryProductCatalog;
import com.example.orders.model.CustomerTier;
import com.example.orders.pricing.TaxCalculator;
import com.example.orders.service.CreateOrderRequest;
import com.example.orders.service.OrderLineRequest;

class OrderValidatorTest {

    private final OrderValidator validator = new OrderValidator(new InMemoryProductCatalog(), new TaxCalculator());

    private static CreateOrderRequest request(String customerId, String region, List<OrderLineRequest> lines) {
        return new CreateOrderRequest(customerId, CustomerTier.STANDARD, region, lines, null);
    }

    private static CreateOrderRequest validRequest() {
        return request("C-1001", "WA", List.of(new OrderLineRequest("KB-MECH", 1)));
    }

    @Test
    void validate_validRequest_returnsNoErrors() {
        assertThat(validator.validate(validRequest()).isValid()).isTrue();
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "   "})
    void validate_missingCustomer_returnsCustomerRequired(String customerId) {
        ValidationResult result = validator.validate(request(customerId, "WA", validRequest().lines()));

        assertThat(result.errors()).extracting(ValidationError::code).contains(ValidationCodes.CUSTOMER_REQUIRED);
    }

    @Test
    void validate_unsupportedRegion_returnsUnsupportedRegion() {
        ValidationResult result = validator.validate(request("C-1001", "ZZ", validRequest().lines()));

        assertThat(result.errors()).extracting(ValidationError::code).contains(ValidationCodes.UNSUPPORTED_REGION);
    }

    @Test
    void validate_noLines_returnsNoLines() {
        ValidationResult result = validator.validate(request("C-1001", "WA", List.of()));

        assertThat(result.errors()).extracting(ValidationError::code).contains(ValidationCodes.NO_LINES);
    }

    @ParameterizedTest
    @ValueSource(ints = {0, -3})
    void validate_quantityNotPositive_returnsQuantityNotPositive(int quantity) {
        ValidationResult result = validator.validate(
                request("C-1001", "WA", List.of(new OrderLineRequest("KB-MECH", quantity))));

        assertThat(result.errors()).singleElement()
                .extracting(ValidationError::code).isEqualTo(ValidationCodes.QUANTITY_NOT_POSITIVE);
    }

    @Test
    void validate_unknownSku_returnsUnknownSku() {
        ValidationResult result = validator.validate(
                request("C-1001", "WA", List.of(new OrderLineRequest("NOPE-1", 1))));

        assertThat(result.errors()).singleElement().satisfies(error -> {
            assertThat(error.code()).isEqualTo(ValidationCodes.UNKNOWN_SKU);
            assertThat(error.message()).contains("NOPE-1");
        });
    }
}
