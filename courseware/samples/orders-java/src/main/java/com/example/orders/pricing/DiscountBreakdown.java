package com.example.orders.pricing;

import java.math.BigDecimal;

public record DiscountBreakdown(BigDecimal bulkDiscount, BigDecimal orderDiscount, BigDecimal couponDiscount) {

    public static final DiscountBreakdown NONE =
            new DiscountBreakdown(Money.ZERO, Money.ZERO, Money.ZERO);

    public BigDecimal total() {
        return bulkDiscount.add(orderDiscount).add(couponDiscount);
    }
}
