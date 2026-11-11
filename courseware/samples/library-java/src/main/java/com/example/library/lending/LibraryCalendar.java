package com.example.library.lending;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Set;

import org.springframework.stereotype.Component;

/** The days the library is closed: every Sunday, plus the public holidays below. */
@Component
public class LibraryCalendar {

    private static final Set<LocalDate> HOLIDAYS = Set.of(
            LocalDate.of(2026, 1, 1),
            LocalDate.of(2026, 5, 25),
            LocalDate.of(2026, 7, 4),
            LocalDate.of(2026, 9, 7),
            LocalDate.of(2026, 11, 26),
            LocalDate.of(2026, 12, 25),
            LocalDate.of(2027, 1, 1));

    public boolean isClosed(LocalDate date) {
        return date.getDayOfWeek() == DayOfWeek.SUNDAY || HOLIDAYS.contains(date);
    }
}
