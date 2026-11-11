package com.example.orders.model;

import java.math.BigDecimal;

/** One line of an order. The unit price is captured from the catalog when the order is placed. */
public record OrderLine(String sku, int quantity, BigDecimal unitPrice) {

    public BigDecimal lineTotal() {
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
}
