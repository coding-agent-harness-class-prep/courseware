package com.example.library.model;

import java.math.BigDecimal;

public class Member {

    private final String id;
    private final String name;
    private final MemberType type;
    private BigDecimal outstandingFines;

    public Member(String id, String name, MemberType type, BigDecimal outstandingFines) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.outstandingFines = outstandingFines;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public MemberType getType() {
        return type;
    }

    /** Late fees the member owes and has not paid yet. */
    public BigDecimal getOutstandingFines() {
        return outstandingFines;
    }

    public void addFine(BigDecimal amount) {
        outstandingFines = outstandingFines.add(amount);
    }
}
