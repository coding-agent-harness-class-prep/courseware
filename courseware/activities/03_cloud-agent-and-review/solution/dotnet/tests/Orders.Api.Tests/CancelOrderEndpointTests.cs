using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Orders.Api.Tests;

public class CancelOrderEndpointTests(WebApplicationFactory<Program> factory) : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client = factory.CreateClient();

    private async Task<string> PlaceOrderAsync()
    {
        var response = await _client.PostAsJsonAsync("/orders", new
        {
            customerId = "C-1001",
            customerTier = "Standard",
            region = "OR",
            lines = new[] { new { sku = "MS-WL", quantity = 1 } },
        }, TestContext.Current.CancellationToken);

        return response.Headers.Location!.OriginalString;
    }

    [Fact]
    public async Task Cancel_PendingOrder_Returns200WithCanceledStatus()
    {
        var location = await PlaceOrderAsync();

        var response = await _client.PostAsync($"{location}/cancel", null, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var order = await response.Content.ReadFromJsonAsync<JsonElement>(TestContext.Current.CancellationToken);
        Assert.Equal("Canceled", order.GetProperty("status").GetString());
    }

    [Fact]
    public async Task Cancel_UnknownOrder_Returns404()
    {
        var response = await _client.PostAsync($"/orders/{Guid.NewGuid()}/cancel", null, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task Cancel_AlreadyCanceled_Returns409()
    {
        var location = await PlaceOrderAsync();
        await _client.PostAsync($"{location}/cancel", null, TestContext.Current.CancellationToken);

        var response = await _client.PostAsync($"{location}/cancel", null, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
    }
}
