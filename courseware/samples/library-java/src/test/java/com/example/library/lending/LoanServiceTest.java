package com.example.library.lending;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;

import com.example.library.fees.LateFeeCalculator;
import com.example.library.model.Loan;

class LoanServiceTest {

    private static final String EFFECTIVE_JAVA = "9780134685991";

    // Monday 1 June 2026: an ordinary open day, well clear of any holiday.
    private final MutableClock clock = new MutableClock(LocalDate.of(2026, 6, 1));
    private final MemberDirectory members = new MemberDirectory();
    private final LoanService service = new LoanService(new BookCatalog(), members, new LoanRepository(),
            new LoanPolicy(), new DueDateCalculator(new LibraryCalendar()), new LateFeeCalculator(), clock);

    @Test
    void borrow_adultMember_isDueInFourteenDays() {
        BorrowOutcome outcome = service.borrow("M-100", EFFECTIVE_JAVA);

        assertThat(outcome.status()).isEqualTo(BorrowOutcome.Status.BORROWED);
        assertThat(outcome.loan().getDueOn()).isEqualTo(LocalDate.of(2026, 6, 15));
    }

    @Test
    void borrow_studentMember_isDueInTwentyOneDays() {
        assertThat(service.borrow("M-200", EFFECTIVE_JAVA).loan().getDueOn()).isEqualTo(LocalDate.of(2026, 6, 22));
    }

    @Test
    void borrow_unknownMember_returnsMemberNotFound() {
        assertThat(service.borrow("M-999", EFFECTIVE_JAVA).status())
                .isEqualTo(BorrowOutcome.Status.MEMBER_NOT_FOUND);
    }

    @Test
    void borrow_lastCopyAlreadyOut_returnsNotAllowed() {
        String csharpInDepth = "9781617294532"; // one copy only
        service.borrow("M-100", csharpInDepth);

        BorrowOutcome outcome = service.borrow("M-200", csharpInDepth);

        assertThat(outcome.status()).isEqualTo(BorrowOutcome.Status.NOT_ALLOWED);
        assertThat(outcome.policy().violations())
                .extracting(PolicyViolation::code).contains(PolicyCodes.NO_COPIES_AVAILABLE);
    }

    @Test
    void return_onTime_chargesNothing() {
        Loan loan = service.borrow("M-100", EFFECTIVE_JAVA).loan();
        clock.setToday(loan.getDueOn());

        Loan returned = service.returnLoan(loan.getId()).orElseThrow();

        assertThat(returned.getLateFee()).isEqualByComparingTo("0.00");
        assertThat(members.find("M-100").orElseThrow().getOutstandingFines()).isEqualByComparingTo("0.00");
    }

    @Test
    void return_fiveDaysLate_addsFeeToMemberFines() {
        Loan loan = service.borrow("M-100", EFFECTIVE_JAVA).loan();
        clock.setToday(loan.getDueOn().plusDays(5));

        Loan returned = service.returnLoan(loan.getId()).orElseThrow();

        assertThat(returned.getLateFee()).isEqualByComparingTo("1.25");
        assertThat(members.find("M-100").orElseThrow().getOutstandingFines()).isEqualByComparingTo("1.25");
        assertThat(returned.isActive()).isFalse();
    }
}
