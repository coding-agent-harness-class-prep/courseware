package com.example.library.lending;

/** Stable violation codes returned to API clients. Never renumber an existing code. */
public final class PolicyCodes {

    public static final String LOAN_LIMIT_REACHED = "LIB001";
    public static final String NO_COPIES_AVAILABLE = "LIB002";

    private PolicyCodes() {
    }
}
