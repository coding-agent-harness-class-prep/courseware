package com.example.library.lending;

import java.util.List;

public record PolicyResult(List<PolicyViolation> violations) {

    public static final PolicyResult ALLOWED = new PolicyResult(List.of());

    public PolicyResult {
        violations = List.copyOf(violations);
    }

    public boolean isAllowed() {
        return violations.isEmpty();
    }
}
