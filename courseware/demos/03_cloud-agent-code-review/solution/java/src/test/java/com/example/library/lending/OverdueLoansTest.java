package com.example.library.lending;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;

import com.example.library.fees.LateFeeCalculator;
import com.example.library.model.Loan;

class OverdueLoansTest {

    private final MutableClock clock = new MutableClock(LocalDate.of(2026, 6, 1));
    private final LoanService service = new LoanService(new BookCatalog(), new MemberDirectory(), new LoanRepository(),
            new LoanPolicy(), new DueDateCalculator(new LibraryCalendar()), new LateFeeCalculator(), clock);

    @Test
    void overdue_nothingPastDue_isEmpty() {
        service.borrow("M-100", "9780134685991");

        assertThat(service.overdue()).isEmpty();
    }

    @Test
    void overdue_loanPastDue_reportsDaysAndFee() {
        Loan loan = service.borrow("M-100", "9780134685991").loan();
        clock.setToday(loan.getDueOn().plusDays(5));

        assertThat(service.overdue()).singleElement().satisfies(o -> {
            assertThat(o.loanId()).isEqualTo(loan.getId());
            assertThat(o.daysOverdue()).isEqualTo(5);
            assertThat(o.feeIfReturnedToday()).isEqualByComparingTo("1.25");
        });
    }

    @Test
    void overdue_severalLoans_mostOverdueFirstAndReturnedLoansLeftOut() {
        Loan adult = service.borrow("M-100", "9780134685991").loan();     // due 15 June
        Loan student = service.borrow("M-200", "9780321125217").loan();   // due 22 June
        Loan returned = service.borrow("M-100", "9780135957059").loan();
        service.returnLoan(returned.getId());
        clock.setToday(LocalDate.of(2026, 6, 30));

        assertThat(service.overdue()).extracting(OverdueLoan::loanId).containsExactly(adult.getId(), student.getId());
    }
}
