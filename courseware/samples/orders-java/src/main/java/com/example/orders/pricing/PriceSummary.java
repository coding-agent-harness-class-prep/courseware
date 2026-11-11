package com.example.orders.pricing;

import java.math.BigDecimal;

public record PriceSummary(BigDecimal subtotal, DiscountBreakdown discounts, BigDecimal tax, BigDecimal total) {
}
