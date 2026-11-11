package com.example.orders.validation;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Component;

import com.example.orders.catalog.ProductCatalog;
import com.example.orders.pricing.TaxCalculator;
import com.example.orders.service.CreateOrderRequest;
import com.example.orders.service.OrderLineRequest;

@Component
public class OrderValidator {

    /** The most units of one SKU the warehouse can pick for a single order line. */
    public static final int MAX_QUANTITY_PER_LINE = 999;

    private final ProductCatalog catalog;
    private final TaxCalculator taxCalculator;

    public OrderValidator(ProductCatalog catalog, TaxCalculator taxCalculator) {
        this.catalog = catalog;
        this.taxCalculator = taxCalculator;
    }

    public ValidationResult validate(CreateOrderRequest request) {
        List<ValidationError> errors = new ArrayList<>();

        if (request.customerId() == null || request.customerId().isBlank()) {
            errors.add(new ValidationError(ValidationCodes.CUSTOMER_REQUIRED, "A customer ID is required."));
        }

        if (!taxCalculator.isSupportedRegion(request.region())) {
            errors.add(new ValidationError(ValidationCodes.UNSUPPORTED_REGION,
                    "We don't ship to region '" + request.region() + "'."));
        }

        List<OrderLineRequest> lines = request.lines() == null ? List.of() : request.lines();
        if (lines.isEmpty()) {
            errors.add(new ValidationError(ValidationCodes.NO_LINES, "An order needs at least one line."));
        }

        for (OrderLineRequest line : lines) {
            if (line.quantity() <= 0) {
                errors.add(new ValidationError(ValidationCodes.QUANTITY_NOT_POSITIVE,
                        "The quantity for " + line.sku() + " must be at least 1."));
            } else if (line.quantity() > MAX_QUANTITY_PER_LINE) {
                errors.add(new ValidationError(ValidationCodes.QUANTITY_ABOVE_LIMIT,
                        "The quantity for " + line.sku() + " can't be more than " + MAX_QUANTITY_PER_LINE + "."));
            }

            if (catalog.find(line.sku()).isEmpty()) {
                errors.add(new ValidationError(ValidationCodes.UNKNOWN_SKU, line.sku() + " is not in the catalog."));
            }
        }

        return errors.isEmpty() ? ValidationResult.VALID : new ValidationResult(errors);
    }
}
