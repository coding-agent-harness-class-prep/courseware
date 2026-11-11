package com.example.orders.service;

import java.util.List;

import com.example.orders.model.CustomerTier;

public record CreateOrderRequest(
        String customerId,
        CustomerTier customerTier,
        String region,
        List<OrderLineRequest> lines,
        String couponCode) {
}
