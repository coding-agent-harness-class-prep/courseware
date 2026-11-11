package com.example.orders.pricing;

import java.math.BigDecimal;

/** Shared money constants. Amounts are BigDecimal with two decimal places. */
public final class Money {

    public static final BigDecimal ZERO = new BigDecimal("0.00");

    private Money() {
    }
}
