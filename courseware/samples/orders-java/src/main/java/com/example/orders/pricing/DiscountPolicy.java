package com.example.orders.pricing;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.example.orders.model.CustomerTier;
import com.example.orders.model.OrderLine;

/**
 * The commercial discount rules agreed with Sales. Bulk discounts are applied per line first;
 * the order-level discount and the welcome coupon are worked out on what is left.
 */
@Component
public class DiscountPolicy {

    private static final int BULK_QUANTITY = 50;
    private static final BigDecimal BULK_RATE = new BigDecimal("0.08");
    private static final BigDecimal ORDER_DISCOUNT_CAP = new BigDecimal("0.12");
    private static final String WELCOME_COUPON = "WELCOME10";
    private static final BigDecimal WELCOME_COUPON_AMOUNT = new BigDecimal("10.00");

    private record VolumeTier(BigDecimal threshold, BigDecimal rate) {
    }

    // Highest threshold first: the first tier the amount reaches wins.
    private static final List<VolumeTier> VOLUME_TIERS = List.of(
            new VolumeTier(new BigDecimal("5000"), new BigDecimal("0.10")),
            new VolumeTier(new BigDecimal("1000"), new BigDecimal("0.05")));

    private static final Map<CustomerTier, BigDecimal> LOYALTY_BONUS = Map.of(
            CustomerTier.STANDARD, BigDecimal.ZERO,
            CustomerTier.SILVER, new BigDecimal("0.02"),
            CustomerTier.GOLD, new BigDecimal("0.04"));

    public DiscountBreakdown calculate(List<OrderLine> lines, CustomerTier tier, String couponCode) {
        if (lines.isEmpty()) {
            return DiscountBreakdown.NONE;
        }

        BigDecimal bulk = lines.stream()
                .filter(l -> l.quantity() >= BULK_QUANTITY)
                .map(l -> round(l.lineTotal().multiply(BULK_RATE)))
                .reduce(Money.ZERO, BigDecimal::add);

        BigDecimal afterBulk = lines.stream()
                .map(OrderLine::lineTotal)
                .reduce(Money.ZERO, BigDecimal::add)
                .subtract(bulk);

        BigDecimal rate = VOLUME_TIERS.stream()
                .filter(t -> afterBulk.compareTo(t.threshold()) >= 0)
                .map(VolumeTier::rate)
                .findFirst()
                .orElse(BigDecimal.ZERO)
                .add(LOYALTY_BONUS.get(tier));
        BigDecimal orderDiscount = round(afterBulk.multiply(rate.min(ORDER_DISCOUNT_CAP)));

        BigDecimal coupon = Money.ZERO;
        if (orderDiscount.signum() == 0 && WELCOME_COUPON.equalsIgnoreCase(couponCode)) {
            coupon = WELCOME_COUPON_AMOUNT.min(afterBulk);
        }

        return new DiscountBreakdown(bulk, orderDiscount, coupon);
    }

    private static BigDecimal round(BigDecimal amount) {
        return amount.setScale(2, RoundingMode.HALF_UP);
    }
}
