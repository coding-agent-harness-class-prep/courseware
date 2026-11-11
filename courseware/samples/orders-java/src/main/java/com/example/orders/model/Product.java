package com.example.orders.model;

import java.math.BigDecimal;

public record Product(String sku, String name, BigDecimal unitPrice) {
}
