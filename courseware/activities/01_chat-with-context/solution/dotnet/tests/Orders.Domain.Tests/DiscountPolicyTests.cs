using Orders.Domain.Model;
using Orders.Domain.Pricing;

namespace Orders.Domain.Tests;

// Reference answer for Activity 01. Your Copilot-generated tests will look different;
// compare which rules they cover, not how they're written.
public class DiscountPolicyTests
{
    private readonly DiscountPolicy _policy = new();

    private static OrderLine Line(int quantity, decimal unitPrice) => new("SKU-1", quantity, unitPrice);

    [Fact]
    public void Calculate_NoLines_ReturnsNoDiscount()
    {
        Assert.Equal(DiscountBreakdown.None, _policy.Calculate([], CustomerTier.Gold, "WELCOME10"));
    }

    [Fact]
    public void Calculate_SmallStandardOrder_ReturnsNoDiscount()
    {
        var result = _policy.Calculate([Line(2, 100m)], CustomerTier.Standard, null);

        Assert.Equal(0m, result.Total);
    }

    [Theory]
    [InlineData(49, 0)]       // one short of the bulk quantity
    [InlineData(50, 33.60)]   // 50 × 8.40 = 420.00, 8% of it
    public void Calculate_LineQuantity_AppliesBulkDiscountFromFiftyUnits(int quantity, double expectedBulk)
    {
        var result = _policy.Calculate([Line(quantity, 8.40m)], CustomerTier.Standard, null);

        Assert.Equal((decimal)expectedBulk, result.BulkDiscount);
    }

    [Theory]
    [InlineData(999.99, 0)]
    [InlineData(1000.00, 50.00)]   // 5% tier
    [InlineData(5000.00, 500.00)]  // 10% tier: the highest tier reached wins, they don't add up
    public void Calculate_StandardCustomer_AppliesVolumeTier(double subtotal, double expectedOrderDiscount)
    {
        var result = _policy.Calculate([Line(1, (decimal)subtotal)], CustomerTier.Standard, null);

        Assert.Equal((decimal)expectedOrderDiscount, result.OrderDiscount);
    }

    [Fact]
    public void Calculate_BulkDiscountTakesOrderBelowVolumeThreshold_AppliesNoVolumeDiscount()
    {
        // 50 × 21.00 = 1,050.00, but the 84.00 bulk discount leaves 966.00, under the 1,000 tier.
        var result = _policy.Calculate([Line(50, 21.00m)], CustomerTier.Standard, null);

        Assert.Equal(84.00m, result.BulkDiscount);
        Assert.Equal(0m, result.OrderDiscount);
    }

    [Theory]
    [InlineData(CustomerTier.Silver, 10.00)]   // 2% of 500
    [InlineData(CustomerTier.Gold, 20.00)]     // 4% of 500
    public void Calculate_LoyaltyTier_AddsBonusEvenBelowVolumeTiers(CustomerTier tier, double expected)
    {
        var result = _policy.Calculate([Line(1, 500m)], tier, null);

        Assert.Equal((decimal)expected, result.OrderDiscount);
    }

    [Fact]
    public void Calculate_GoldAtTopTier_CapsOrderDiscountAtTwelvePercent()
    {
        // 10% volume + 4% loyalty = 14%, capped at 12% of 6,000.
        var result = _policy.Calculate([Line(1, 6000m)], CustomerTier.Gold, null);

        Assert.Equal(720.00m, result.OrderDiscount);
    }

    [Theory]
    [InlineData("WELCOME10")]
    [InlineData("welcome10")]
    public void Calculate_WelcomeCouponWithNoOtherOrderDiscount_TakesTenOff(string coupon)
    {
        var result = _policy.Calculate([Line(1, 200m)], CustomerTier.Standard, coupon);

        Assert.Equal(10m, result.CouponDiscount);
    }

    [Fact]
    public void Calculate_WelcomeCouponWhenOrderDiscountApplies_IsIgnored()
    {
        // A Silver customer always gets the loyalty bonus, so the coupon never stacks for them.
        var result = _policy.Calculate([Line(1, 200m)], CustomerTier.Silver, "WELCOME10");

        Assert.Equal(0m, result.CouponDiscount);
        Assert.Equal(4.00m, result.OrderDiscount);
    }

    [Fact]
    public void Calculate_WelcomeCouponOnTinyOrder_NeverExceedsTheAmount()
    {
        var result = _policy.Calculate([Line(1, 6.00m)], CustomerTier.Standard, "WELCOME10");

        Assert.Equal(6.00m, result.CouponDiscount);
    }

    [Fact]
    public void Calculate_UnknownCoupon_IsIgnored()
    {
        var result = _policy.Calculate([Line(1, 200m)], CustomerTier.Standard, "SPRING25");

        Assert.Equal(0m, result.Total);
    }
}
