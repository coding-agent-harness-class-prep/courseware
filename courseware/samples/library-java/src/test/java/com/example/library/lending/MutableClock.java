package com.example.library.lending;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZoneOffset;

/** A clock the test can set and move forward. */
public class MutableClock extends Clock {

    private LocalDate today;

    public MutableClock(LocalDate today) {
        this.today = today;
    }

    public void setToday(LocalDate today) {
        this.today = today;
    }

    @Override
    public ZoneId getZone() {
        return ZoneOffset.UTC;
    }

    @Override
    public Clock withZone(ZoneId zone) {
        return this;
    }

    @Override
    public Instant instant() {
        return today.atTime(12, 0).toInstant(ZoneOffset.UTC);
    }
}
