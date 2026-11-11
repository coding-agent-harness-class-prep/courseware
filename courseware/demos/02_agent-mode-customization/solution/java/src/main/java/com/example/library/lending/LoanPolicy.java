package com.example.library.lending;

import java.math.BigDecimal;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.example.library.model.Book;
import com.example.library.model.Member;
import com.example.library.model.MemberType;

/** Decides whether a member may borrow a book right now. */
@Component
public class LoanPolicy {

    /** Members who owe more than this must pay before they can borrow again. */
    public static final BigDecimal MAX_OUTSTANDING_FINES = new BigDecimal("10.00");

    private static final Map<MemberType, Integer> LOAN_LIMITS = Map.of(
            MemberType.ADULT, 5,
            MemberType.STUDENT, 3,
            MemberType.SENIOR, 5);

    public PolicyResult canBorrow(Member member, Book book, long activeLoansForMember, long activeLoansForBook) {
        List<PolicyViolation> violations = new ArrayList<>();

        if (activeLoansForMember >= LOAN_LIMITS.get(member.getType())) {
            violations.add(new PolicyViolation(PolicyCodes.LOAN_LIMIT_REACHED,
                    member.getName() + " already has " + activeLoansForMember
                            + " books out, the limit for this membership."));
        }

        if (member.getOutstandingFines().compareTo(MAX_OUTSTANDING_FINES) > 0) {
            violations.add(new PolicyViolation(PolicyCodes.FINES_OUTSTANDING,
                    member.getName() + " owes " + member.getOutstandingFines() + " in fines; the limit is "
                            + MAX_OUTSTANDING_FINES + "."));
        }

        if (activeLoansForBook >= book.copies()) {
            violations.add(new PolicyViolation(PolicyCodes.NO_COPIES_AVAILABLE,
                    "Every copy of \"" + book.title() + "\" is on loan."));
        }

        return violations.isEmpty() ? PolicyResult.ALLOWED : new PolicyResult(violations);
    }
}
