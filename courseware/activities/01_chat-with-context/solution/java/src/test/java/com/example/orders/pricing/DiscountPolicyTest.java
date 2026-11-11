package com.example.orders.pricing;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;

import com.example.orders.model.CustomerTier;
import com.example.orders.model.OrderLine;

// Reference answer for Activity 01. Your Copilot-generated tests will look different;
// compare which rules they cover, not how they're written.
class DiscountPolicyTest {

    private final DiscountPolicy policy = new DiscountPolicy();

    private static List<OrderLine> line(int quantity, String unitPrice) {
        return List.of(new OrderLine("SKU-1", quantity, new BigDecimal(unitPrice)));
    }

    @Test
    void calculate_noLines_returnsNoDiscount() {
        assertThat(policy.calculate(List.of(), CustomerTier.GOLD, "WELCOME10")).isEqualTo(DiscountBreakdown.NONE);
    }

    @Test
    void calculate_smallStandardOrder_returnsNoDiscount() {
        assertThat(policy.calculate(line(2, "100.00"), CustomerTier.STANDARD, null).total())
                .isEqualByComparingTo("0");
    }

    @ParameterizedTest
    @CsvSource({
            "49, 0",        // one short of the bulk quantity
            "50, 33.60"     // 50 x 8.40 = 420.00, 8% of it
    })
    void calculate_lineQuantity_appliesBulkDiscountFromFiftyUnits(int quantity, String expectedBulk) {
        assertThat(policy.calculate(line(quantity, "8.40"), CustomerTier.STANDARD, null).bulkDiscount())
                .isEqualByComparingTo(expectedBulk);
    }

    @ParameterizedTest
    @CsvSource({
            "999.99, 0",
            "1000.00, 50.00",    // 5% tier
            "5000.00, 500.00"    // 10% tier: the highest tier reached wins, they don't add up
    })
    void calculate_standardCustomer_appliesVolumeTier(String subtotal, String expectedOrderDiscount) {
        assertThat(policy.calculate(line(1, subtotal), CustomerTier.STANDARD, null).orderDiscount())
                .isEqualByComparingTo(expectedOrderDiscount);
    }

    @Test
    void calculate_bulkDiscountTakesOrderBelowVolumeThreshold_appliesNoVolumeDiscount() {
        // 50 x 21.00 = 1,050.00, but the 84.00 bulk discount leaves 966.00, under the 1,000 tier.
        DiscountBreakdown result = policy.calculate(line(50, "21.00"), CustomerTier.STANDARD, null);

        assertThat(result.bulkDiscount()).isEqualByComparingTo("84.00");
        assertThat(result.orderDiscount()).isEqualByComparingTo("0");
    }

    @ParameterizedTest
    @CsvSource({
            "SILVER, 10.00",    // 2% of 500
            "GOLD, 20.00"       // 4% of 500
    })
    void calculate_loyaltyTier_addsBonusEvenBelowVolumeTiers(CustomerTier tier, String expected) {
        assertThat(policy.calculate(line(1, "500.00"), tier, null).orderDiscount()).isEqualByComparingTo(expected);
    }

    @Test
    void calculate_goldAtTopTier_capsOrderDiscountAtTwelvePercent() {
        // 10% volume + 4% loyalty = 14%, capped at 12% of 6,000.
        assertThat(policy.calculate(line(1, "6000.00"), CustomerTier.GOLD, null).orderDiscount())
                .isEqualByComparingTo("720.00");
    }

    @ParameterizedTest
    @ValueSource(strings = {"WELCOME10", "welcome10"})
    void calculate_welcomeCouponWithNoOtherOrderDiscount_takesTenOff(String coupon) {
        assertThat(policy.calculate(line(1, "200.00"), CustomerTier.STANDARD, coupon).couponDiscount())
                .isEqualByComparingTo("10.00");
    }

    @Test
    void calculate_welcomeCouponWhenOrderDiscountApplies_isIgnored() {
        // A Silver customer always gets the loyalty bonus, so the coupon never stacks for them.
        DiscountBreakdown result = policy.calculate(line(1, "200.00"), CustomerTier.SILVER, "WELCOME10");

        assertThat(result.couponDiscount()).isEqualByComparingTo("0");
        assertThat(result.orderDiscount()).isEqualByComparingTo("4.00");
    }

    @Test
    void calculate_welcomeCouponOnTinyOrder_neverExceedsTheAmount() {
        assertThat(policy.calculate(line(1, "6.00"), CustomerTier.STANDARD, "WELCOME10").couponDiscount())
                .isEqualByComparingTo("6.00");
    }

    @Test
    void calculate_unknownCoupon_isIgnored() {
        assertThat(policy.calculate(line(1, "200.00"), CustomerTier.STANDARD, "SPRING25").total())
                .isEqualByComparingTo("0");
    }
}
