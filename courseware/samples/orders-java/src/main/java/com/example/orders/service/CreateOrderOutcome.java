package com.example.orders.service;

import java.util.Optional;

import com.example.orders.model.Order;
import com.example.orders.validation.ValidationResult;

/** Either the order that was created, or the validation errors that stopped it. */
public record CreateOrderOutcome(Optional<Order> order, ValidationResult validation) {

    public boolean succeeded() {
        return order.isPresent();
    }
}
