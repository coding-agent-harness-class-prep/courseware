package com.example.library.lending;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record OverdueLoan(UUID loanId, String isbn, String memberId, LocalDate dueOn, long daysOverdue,
        BigDecimal feeIfReturnedToday) {
}
