package com.example.orders.pricing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class TaxCalculatorTest {

    private final TaxCalculator calculator = new TaxCalculator();

    @ParameterizedTest
    @CsvSource({
            "100.00, WA, 6.50",
            "80.00, NY, 3.20",
            "250.00, OR, 0.00"
    })
    void calculate_knownRegion_appliesRegionRate(String amount, String region, String expected) {
        assertThat(calculator.calculate(new BigDecimal(amount), region)).isEqualByComparingTo(expected);
    }

    // Reported in the issue: Finance policy FIN-7 says an exact half cent rounds up.
    @ParameterizedTest
    @CsvSource({
            "8.40, TX, 0.53",     // 8.40 x 6.25% = 0.525
            "18.00, TX, 1.13"     // 18.00 x 6.25% = 1.125
    })
    void calculate_exactHalfCent_roundsUp(String amount, String region, String expected) {
        assertThat(calculator.calculate(new BigDecimal(amount), region)).isEqualByComparingTo(expected);
    }

    @Test
    void calculate_unsupportedRegion_throws() {
        assertThatThrownBy(() -> calculator.calculate(BigDecimal.TEN, "ZZ"))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
