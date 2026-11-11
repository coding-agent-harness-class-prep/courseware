package com.example.orders.model;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.example.orders.pricing.PriceSummary;

public class Order {

    private final UUID id;
    private final String customerId;
    private final CustomerTier customerTier;
    private final String region;
    private final List<OrderLine> lines;
    private final String couponCode;
    private final PriceSummary price;
    private final Instant createdAt;
    private OrderStatus status = OrderStatus.PENDING;

    public Order(UUID id, String customerId, CustomerTier customerTier, String region, List<OrderLine> lines,
            String couponCode, PriceSummary price, Instant createdAt) {
        this.id = id;
        this.customerId = customerId;
        this.customerTier = customerTier;
        this.region = region;
        this.lines = List.copyOf(lines);
        this.couponCode = couponCode;
        this.price = price;
        this.createdAt = createdAt;
    }

    public UUID getId() {
        return id;
    }

    public String getCustomerId() {
        return customerId;
    }

    public CustomerTier getCustomerTier() {
        return customerTier;
    }

    /** Two-letter shipping region, used to look up the sales-tax rate. */
    public String getRegion() {
        return region;
    }

    public List<OrderLine> getLines() {
        return lines;
    }

    public String getCouponCode() {
        return couponCode;
    }

    public PriceSummary getPrice() {
        return price;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }
}
