package com.example.library.lending;

import java.time.LocalDate;

import org.springframework.stereotype.Component;

import com.example.library.model.MemberType;

/**
 * Works out when a loan is due from the member type and the library calendar.
 */
@Component
public class DueDateCalculator {

    public static final int STANDARD_LOAN_DAYS = 14;
    public static final int STUDENT_LOAN_DAYS = 21;

    private final LibraryCalendar calendar;

    public DueDateCalculator(LibraryCalendar calendar) {
        this.calendar = calendar;
    }

    public LocalDate dueDate(LocalDate borrowedOn, MemberType memberType) {
        LocalDate due = borrowedOn.plusDays(memberType == MemberType.STUDENT ? STUDENT_LOAN_DAYS : STANDARD_LOAN_DAYS);

        while (calendar.isClosed(due)) {
            due = due.plusDays(1);
        }

        return due;
    }
}
