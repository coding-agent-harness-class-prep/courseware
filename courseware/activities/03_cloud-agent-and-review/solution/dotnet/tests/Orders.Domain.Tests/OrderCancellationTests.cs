using Orders.Domain.Catalog;
using Orders.Domain.Model;
using Orders.Domain.Ordering;
using Orders.Domain.Pricing;
using Orders.Domain.Validation;

namespace Orders.Domain.Tests;

public class OrderCancellationTests
{
    private readonly OrderService _service;

    public OrderCancellationTests()
    {
        var catalog = new InMemoryProductCatalog();
        var tax = new TaxCalculator();
        _service = new OrderService(new InMemoryOrderRepository(), catalog, new OrderValidator(catalog, tax),
            new DiscountPolicy(), tax, TimeProvider.System);
    }

    private Order PlaceOrder() =>
        _service.Create(new("C-1001", CustomerTier.Standard, "OR", [new OrderLineRequest("MS-WL", 1)])).Order!;

    [Fact]
    public void Cancel_PendingOrder_MarksItCanceled()
    {
        var order = PlaceOrder();

        Assert.Equal(CancelOutcome.Canceled, _service.Cancel(order.Id));
        Assert.Equal(OrderStatus.Canceled, _service.Find(order.Id)!.Status);
    }

    [Fact]
    public void Cancel_UnknownOrder_ReturnsNotFound()
    {
        Assert.Equal(CancelOutcome.NotFound, _service.Cancel(Guid.NewGuid()));
    }

    [Theory]
    [InlineData(OrderStatus.Paid)]
    [InlineData(OrderStatus.Shipped)]
    [InlineData(OrderStatus.Canceled)]
    public void Cancel_OrderNoLongerPending_ReturnsNotPendingAndLeavesStatus(OrderStatus status)
    {
        var order = PlaceOrder();
        order.Status = status;

        Assert.Equal(CancelOutcome.NotPending, _service.Cancel(order.Id));
        Assert.Equal(status, order.Status);
    }
}
