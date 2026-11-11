using System.Globalization;
using Orders.Domain.Pricing;

namespace Orders.Domain.Tests;

public class TaxCalculatorTests
{
    private readonly TaxCalculator _calculator = new();

    private static decimal D(string value) => decimal.Parse(value, CultureInfo.InvariantCulture);

    [Theory]
    [InlineData("100.00", "WA", "6.50")]
    [InlineData("80.00", "NY", "3.20")]
    [InlineData("250.00", "OR", "0.00")]
    public void Calculate_KnownRegion_AppliesRegionRate(string amount, string region, string expected)
    {
        Assert.Equal(D(expected), _calculator.Calculate(D(amount), region));
    }

    // Reported in the issue: Finance policy FIN-7 says an exact half cent rounds up.
    [Theory]
    [InlineData("8.40", "TX", "0.53")]    // 8.40 x 6.25% = 0.525
    [InlineData("18.00", "TX", "1.13")]   // 18.00 x 6.25% = 1.125
    public void Calculate_ExactHalfCent_RoundsUp(string amount, string region, string expected)
    {
        Assert.Equal(D(expected), _calculator.Calculate(D(amount), region));
    }

    [Fact]
    public void Calculate_UnsupportedRegion_Throws()
    {
        Assert.Throws<ArgumentException>(() => _calculator.Calculate(10m, "ZZ"));
    }
}
