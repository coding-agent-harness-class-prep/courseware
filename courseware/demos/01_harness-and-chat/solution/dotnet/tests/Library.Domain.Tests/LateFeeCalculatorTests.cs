using Library.Domain.Fees;
using Library.Domain.Model;

namespace Library.Domain.Tests;

// The reference result of Demo 01, for when the live run goes somewhere else.
public class LateFeeCalculatorTests
{
    private static readonly DateOnly Due = new(2026, 6, 15);

    private readonly LateFeeCalculator _calculator = new();

    [Theory]
    [InlineData(-3)]   // returned early
    [InlineData(0)]    // on the due date
    [InlineData(2)]    // last day of the grace period
    public void Calculate_WithinGracePeriod_ChargesNothing(int daysLate)
    {
        Assert.Equal(0m, _calculator.Calculate(Due, Due.AddDays(daysLate), MemberType.Adult));
    }

    [Fact]
    public void Calculate_FirstDayPastGrace_ChargesForEveryLateDay()
    {
        // Three days late: all three are charged, not just the one past the grace period.
        Assert.Equal(0.75m, _calculator.Calculate(Due, Due.AddDays(3), MemberType.Adult));
    }

    [Fact]
    public void Calculate_Student_PaysHalfRate()
    {
        Assert.Equal(0.63m, _calculator.Calculate(Due, Due.AddDays(5), MemberType.Student)); // 1.25 / 2 = 0.625
    }

    [Theory]
    [InlineData(7, 0)]       // the first seven days are free for seniors
    [InlineData(10, 0.75)]   // three chargeable days
    public void Calculate_Senior_GetsSevenFeeFreeDays(int daysLate, double expected)
    {
        Assert.Equal((decimal)expected, _calculator.Calculate(Due, Due.AddDays(daysLate), MemberType.Senior));
    }

    [Fact]
    public void Calculate_VeryLate_IsCappedPerLoan()
    {
        Assert.Equal(10.00m, _calculator.Calculate(Due, Due.AddDays(90), MemberType.Adult));
    }
}
