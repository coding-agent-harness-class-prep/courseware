package com.example.library.lending;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.library.fees.LateFeeCalculator;
import com.example.library.model.Book;
import com.example.library.model.Loan;
import com.example.library.model.Member;

@Service
public class LoanService {

    private final BookCatalog books;
    private final MemberDirectory members;
    private final LoanRepository loans;
    private final LoanPolicy policy;
    private final DueDateCalculator dueDates;
    private final LateFeeCalculator lateFees;
    private final Clock clock;

    public LoanService(BookCatalog books, MemberDirectory members, LoanRepository loans, LoanPolicy policy,
            DueDateCalculator dueDates, LateFeeCalculator lateFees, Clock clock) {
        this.books = books;
        this.members = members;
        this.loans = loans;
        this.policy = policy;
        this.dueDates = dueDates;
        this.lateFees = lateFees;
        this.clock = clock;
    }

    public BorrowOutcome borrow(String memberId, String isbn) {
        Optional<Member> member = members.find(memberId);
        if (member.isEmpty()) {
            return BorrowOutcome.of(BorrowOutcome.Status.MEMBER_NOT_FOUND);
        }

        Optional<Book> book = books.find(isbn);
        if (book.isEmpty()) {
            return BorrowOutcome.of(BorrowOutcome.Status.BOOK_NOT_FOUND);
        }

        List<Loan> active = loans.active();
        PolicyResult verdict = policy.canBorrow(
                member.get(),
                book.get(),
                active.stream().filter(l -> l.getMemberId().equals(memberId)).count(),
                active.stream().filter(l -> l.getIsbn().equals(isbn)).count());

        if (!verdict.isAllowed()) {
            return new BorrowOutcome(BorrowOutcome.Status.NOT_ALLOWED, null, verdict);
        }

        LocalDate today = LocalDate.now(clock);
        Loan loan = new Loan(UUID.randomUUID(), isbn, memberId, today,
                dueDates.dueDate(today, member.get().getType()));

        loans.save(loan);
        return new BorrowOutcome(BorrowOutcome.Status.BORROWED, loan, verdict);
    }

    /** Records a return and adds any late fee to the member's outstanding fines. */
    public Optional<Loan> returnLoan(UUID loanId) {
        Optional<Loan> found = loans.find(loanId).filter(Loan::isActive);
        if (found.isEmpty()) {
            return Optional.empty();
        }

        Loan loan = found.get();
        Member member = members.find(loan.getMemberId()).orElseThrow();
        LocalDate today = LocalDate.now(clock);
        BigDecimal fee = lateFees.calculate(loan.getDueOn(), today, member.getType());

        loan.markReturned(today, fee);
        member.addFine(fee);
        loans.save(loan);
        return Optional.of(loan);
    }

    /** Active loans past their due date, most overdue first, with the fee owed if returned today. */
    public List<OverdueLoan> overdue() {
        LocalDate today = LocalDate.now(clock);
        return loans.active().stream()
                .filter(l -> l.getDueOn().isBefore(today))
                .map(l -> new OverdueLoan(
                        l.getId(),
                        l.getIsbn(),
                        l.getMemberId(),
                        l.getDueOn(),
                        ChronoUnit.DAYS.between(l.getDueOn(), today),
                        lateFees.calculate(l.getDueOn(), today, members.find(l.getMemberId()).orElseThrow().getType())))
                .sorted(Comparator.comparingLong(OverdueLoan::daysOverdue).reversed())
                .toList();
    }

    public Optional<Loan> find(UUID loanId) {
        return loans.find(loanId);
    }
}
