package com.example.library.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public class Loan {

    private final UUID id;
    private final String isbn;
    private final String memberId;
    private final LocalDate borrowedOn;
    private final LocalDate dueOn;
    private LocalDate returnedOn;
    private BigDecimal lateFee = new BigDecimal("0.00");

    public Loan(UUID id, String isbn, String memberId, LocalDate borrowedOn, LocalDate dueOn) {
        this.id = id;
        this.isbn = isbn;
        this.memberId = memberId;
        this.borrowedOn = borrowedOn;
        this.dueOn = dueOn;
    }

    public UUID getId() {
        return id;
    }

    public String getIsbn() {
        return isbn;
    }

    public String getMemberId() {
        return memberId;
    }

    public LocalDate getBorrowedOn() {
        return borrowedOn;
    }

    public LocalDate getDueOn() {
        return dueOn;
    }

    public LocalDate getReturnedOn() {
        return returnedOn;
    }

    public BigDecimal getLateFee() {
        return lateFee;
    }

    public boolean isActive() {
        return returnedOn == null;
    }

    public void markReturned(LocalDate on, BigDecimal fee) {
        this.returnedOn = on;
        this.lateFee = fee;
    }
}
