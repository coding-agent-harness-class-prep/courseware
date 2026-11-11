package com.example.library.lending;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;

import com.example.library.model.MemberType;

class DueDateCalculatorTest {

    private final DueDateCalculator calculator = new DueDateCalculator(new LibraryCalendar());

    @Test
    void dueDate_openDay_isFourteenDaysLater() {
        assertThat(calculator.dueDate(LocalDate.of(2026, 6, 1), MemberType.ADULT)).isEqualTo(LocalDate.of(2026, 6, 15));
    }

    @Test
    void dueDate_landsOnHoliday_movesToNextOpenDay() {
        // Thanksgiving, Thursday 26 November 2026, rolls to Friday the 27th.
        assertThat(calculator.dueDate(LocalDate.of(2026, 11, 12), MemberType.ADULT))
                .isEqualTo(LocalDate.of(2026, 11, 27));
    }

    // Reported in the issue: borrowed Saturday 20 June 2026, due 4 July (a holiday) and then
    // Sunday 5 July (closed) - the member was told to return it on a day the doors were shut.
    @Test
    void dueDate_skipsConsecutiveClosedDays() {
        assertThat(calculator.dueDate(LocalDate.of(2026, 6, 20), MemberType.ADULT))
                .isEqualTo(LocalDate.of(2026, 7, 6));
    }
}
