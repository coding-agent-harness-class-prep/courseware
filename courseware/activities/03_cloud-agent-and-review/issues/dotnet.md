Customers sometimes place an order by mistake and then call support to undo it. Support needs an API
call that cancels an order, but only while the order hasn't been paid for or shipped.

## What to build

Add `POST /orders/{id}/cancel`.

- If the order's status is `Pending`, set it to `Canceled` and return **200 OK** with the updated order.
- If no order has that ID, return **404 Not Found**.
- If the order is in any other status (`Paid`, `Shipped`, or already `Canceled`), return
  **409 Conflict** as problem details. The title says only a pending order can be canceled, and the
  detail names the order's current status. Leave the order unchanged.

## Where it goes

- The rule belongs in the domain: add a `Cancel` method to `OrderService`
  (`src/Orders.Domain/Ordering/OrderService.cs`) that reports which of the three outcomes happened.
- `src/Orders.Api/Program.cs` maps the endpoint, the same way the existing `/orders` endpoints are
  mapped.

## Acceptance criteria

- [ ] Domain tests in `tests/Orders.Domain.Tests` cover all three outcomes, including each status that
      isn't `Pending`.
- [ ] Endpoint tests in `tests/Orders.Api.Tests` cover 200, 404, and 409.
- [ ] `dotnet test` passes.
- [ ] `CHANGELOG.md` has an entry under `## [Unreleased]`.

## Out of scope

Refunds, restocking inventory, and any user interface.
