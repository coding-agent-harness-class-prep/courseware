package com.example.library.lending;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import com.example.library.model.Book;
import com.example.library.model.Member;
import com.example.library.model.MemberType;

class LoanPolicyTest {

    private final LoanPolicy policy = new LoanPolicy();

    private static final Book BOOK = new Book("9780134685991", "Effective Java", "Joshua Bloch", 2);

    private static Member memberOf(MemberType type) {
        return new Member("M-1", "Test Member", type, BigDecimal.ZERO);
    }

    @Test
    void canBorrow_underLimitsWithCopiesFree_isAllowed() {
        assertThat(policy.canBorrow(memberOf(MemberType.ADULT), BOOK, 0, 0).isAllowed()).isTrue();
    }

    @ParameterizedTest
    @CsvSource({"ADULT, 5", "STUDENT, 3", "SENIOR, 5"})
    void canBorrow_atLoanLimit_returnsLoanLimitReached(MemberType type, int limit) {
        PolicyResult result = policy.canBorrow(memberOf(type), BOOK, limit, 0);

        assertThat(result.violations()).singleElement()
                .extracting(PolicyViolation::code).isEqualTo(PolicyCodes.LOAN_LIMIT_REACHED);
    }

    @Test
    void canBorrow_studentBelowLimit_isAllowed() {
        assertThat(policy.canBorrow(memberOf(MemberType.STUDENT), BOOK, 2, 0).isAllowed()).isTrue();
    }

    @Test
    void canBorrow_allCopiesOut_returnsNoCopiesAvailable() {
        PolicyResult result = policy.canBorrow(memberOf(MemberType.ADULT), BOOK, 0, 2);

        assertThat(result.violations()).singleElement().satisfies(v -> {
            assertThat(v.code()).isEqualTo(PolicyCodes.NO_COPIES_AVAILABLE);
            assertThat(v.message()).contains("Effective Java");
        });
    }
}
