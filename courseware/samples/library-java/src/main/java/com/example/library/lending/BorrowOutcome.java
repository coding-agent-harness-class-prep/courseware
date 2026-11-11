package com.example.library.lending;

import com.example.library.model.Loan;

public record BorrowOutcome(Status status, Loan loan, PolicyResult policy) {

    public enum Status {
        BORROWED,
        MEMBER_NOT_FOUND,
        BOOK_NOT_FOUND,
        NOT_ALLOWED
    }

    static BorrowOutcome of(Status status) {
        return new BorrowOutcome(status, null, null);
    }
}
