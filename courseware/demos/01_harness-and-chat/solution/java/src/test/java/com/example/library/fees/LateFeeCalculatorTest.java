package com.example.library.fees;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;

import com.example.library.model.MemberType;

// The reference result of Demo 01, for when the live run goes somewhere else.
class LateFeeCalculatorTest {

    private static final LocalDate DUE = LocalDate.of(2026, 6, 15);

    private final LateFeeCalculator calculator = new LateFeeCalculator();

    @ParameterizedTest
    @ValueSource(ints = {-3, 0, 2})   // early, on the due date, last day of grace
    void calculate_withinGracePeriod_chargesNothing(int daysLate) {
        assertThat(calculator.calculate(DUE, DUE.plusDays(daysLate), MemberType.ADULT)).isEqualByComparingTo("0");
    }

    @Test
    void calculate_firstDayPastGrace_chargesForEveryLateDay() {
        // Three days late: all three are charged, not just the one past the grace period.
        assertThat(calculator.calculate(DUE, DUE.plusDays(3), MemberType.ADULT)).isEqualByComparingTo("0.75");
    }

    @Test
    void calculate_student_paysHalfRate() {
        // 1.25 / 2 = 0.625, rounded half-up
        assertThat(calculator.calculate(DUE, DUE.plusDays(5), MemberType.STUDENT)).isEqualByComparingTo("0.63");
    }

    @ParameterizedTest
    @CsvSource({
            "7, 0",        // the first seven days are free for seniors
            "10, 0.75"     // three chargeable days
    })
    void calculate_senior_getsSevenFeeFreeDays(int daysLate, String expected) {
        assertThat(calculator.calculate(DUE, DUE.plusDays(daysLate), MemberType.SENIOR)).isEqualByComparingTo(expected);
    }

    @Test
    void calculate_veryLate_isCappedPerLoan() {
        assertThat(calculator.calculate(DUE, DUE.plusDays(90), MemberType.ADULT)).isEqualByComparingTo("10.00");
    }
}
