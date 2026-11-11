package com.example.orders.pricing;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Locale;
import java.util.Map;

import org.springframework.stereotype.Component;

/**
 * Regional sales tax, charged on the discounted amount (finance policy FIN-7).
 */
@Component
public class TaxCalculator {

    private static final Map<String, BigDecimal> RATES = Map.of(
            "CA", new BigDecimal("0.0725"),
            "NY", new BigDecimal("0.04"),
            "OR", BigDecimal.ZERO,
            "TX", new BigDecimal("0.0625"),
            "WA", new BigDecimal("0.065"));

    public boolean isSupportedRegion(String region) {
        return region != null && RATES.containsKey(region.toUpperCase(Locale.ROOT));
    }

    public BigDecimal calculate(BigDecimal taxableAmount, String region) {
        BigDecimal rate = region == null ? null : RATES.get(region.toUpperCase(Locale.ROOT));
        if (rate == null) {
            throw new IllegalArgumentException("Unsupported region '" + region + "'.");
        }

        return taxableAmount.multiply(rate).setScale(2, RoundingMode.HALF_EVEN);
    }
}
