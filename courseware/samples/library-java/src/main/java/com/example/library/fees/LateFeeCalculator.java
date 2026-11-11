package com.example.library.fees;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import org.springframework.stereotype.Component;

import com.example.library.model.MemberType;

/** Late fees as set by the library board (policy LIB-12). */
@Component
public class LateFeeCalculator {

    private static final int GRACE_DAYS = 2;
    private static final int SENIOR_FEE_FREE_DAYS = 7;
    private static final BigDecimal DAILY_FEE = new BigDecimal("0.25");
    private static final BigDecimal STUDENT_RATE = new BigDecimal("0.5");
    private static final BigDecimal MAX_FEE_PER_LOAN = new BigDecimal("10.00");
    private static final BigDecimal NO_FEE = new BigDecimal("0.00");

    public BigDecimal calculate(LocalDate dueOn, LocalDate returnedOn, MemberType memberType) {
        long daysLate = ChronoUnit.DAYS.between(dueOn, returnedOn);
        if (daysLate <= GRACE_DAYS) {
            return NO_FEE;
        }

        // Past the grace period every late day counts, including the grace days themselves.
        long chargeableDays = memberType == MemberType.SENIOR ? daysLate - SENIOR_FEE_FREE_DAYS : daysLate;
        if (chargeableDays <= 0) {
            return NO_FEE;
        }

        BigDecimal fee = DAILY_FEE.multiply(BigDecimal.valueOf(chargeableDays))
                .multiply(memberType == MemberType.STUDENT ? STUDENT_RATE : BigDecimal.ONE);
        return fee.setScale(2, RoundingMode.HALF_UP).min(MAX_FEE_PER_LOAN);
    }
}
