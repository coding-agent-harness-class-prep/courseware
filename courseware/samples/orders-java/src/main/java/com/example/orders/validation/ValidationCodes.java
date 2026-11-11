package com.example.orders.validation;

/** Stable error codes returned to API clients. Never renumber an existing code. */
public final class ValidationCodes {

    public static final String CUSTOMER_REQUIRED = "ORD001";
    public static final String UNSUPPORTED_REGION = "ORD002";
    public static final String NO_LINES = "ORD003";
    public static final String QUANTITY_NOT_POSITIVE = "ORD004";
    public static final String UNKNOWN_SKU = "ORD005";

    private ValidationCodes() {
    }
}
