package com.example.library.lending;

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

        if (activeLoansForBook >= book.copies()) {
            violations.add(new PolicyViolation(PolicyCodes.NO_COPIES_AVAILABLE,
                    "Every copy of \"" + book.title() + "\" is on loan."));
        }

        return violations.isEmpty() ? PolicyResult.ALLOWED : new PolicyResult(violations);
    }
}
