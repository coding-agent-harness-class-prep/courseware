using Library.Domain.Lending;
using Library.Domain.Model;

namespace Library.Domain.Tests;

public class DueDateCalculatorTests
{
    private readonly DueDateCalculator _calculator = new(new LibraryCalendar());

    [Fact]
    public void DueDate_OpenDay_IsFourteenDaysLater()
    {
        Assert.Equal(new DateOnly(2026, 6, 15), _calculator.DueDate(new DateOnly(2026, 6, 1), MemberType.Adult));
    }

    [Fact]
    public void DueDate_LandsOnHoliday_MovesToNextOpenDay()
    {
        // Thanksgiving, Thursday 26 November 2026, rolls to Friday the 27th.
        Assert.Equal(new DateOnly(2026, 11, 27), _calculator.DueDate(new DateOnly(2026, 11, 12), MemberType.Adult));
    }

    // Reported in the issue: borrowed Saturday 20 June 2026, due 4 July (a holiday) and then
    // Sunday 5 July (closed) — the member was told to return it on a day the doors were shut.
    [Fact]
    public void DueDate_SkipsConsecutiveClosedDays()
    {
        Assert.Equal(new DateOnly(2026, 7, 6), _calculator.DueDate(new DateOnly(2026, 6, 20), MemberType.Adult));
    }
}
