package com.example.orders.validation;

import java.util.List;

public record ValidationResult(List<ValidationError> errors) {

    public static final ValidationResult VALID = new ValidationResult(List.of());

    public ValidationResult {
        errors = List.copyOf(errors);
    }

    public boolean isValid() {
        return errors.isEmpty();
    }
}
