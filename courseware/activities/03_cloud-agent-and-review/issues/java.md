Customers sometimes place an order by mistake and then call support to undo it. Support needs an API
call that cancels an order, but only while the order hasn't been paid for or shipped.

## What to build

Add `POST /orders/{id}/cancel`.

- If the order's status is `PENDING`, set it to `CANCELED` and return **200 OK** with the updated order.
- If no order has that ID, return **404 Not Found**.
- If the order is in any other status (`PAID`, `SHIPPED`, or already `CANCELED`), return
  **409 Conflict** as a `ProblemDetail`. The title says only a pending order can be canceled, and the
  detail names the order's current status. Leave the order unchanged.

## Where it goes

- The rule belongs in the service layer: add a `cancel` method to `OrderService`
  (`src/main/java/com/example/orders/service/OrderService.java`) that reports which of the three
  outcomes happened.
- `OrderController` (`src/main/java/com/example/orders/web/`) maps the endpoint next to the existing
  `/orders` endpoints.

## Acceptance criteria

- [ ] Plain JUnit tests for the service cover all three outcomes, including each status that isn't
      `PENDING`.
- [ ] MockMvc tests for the controller cover 200, 404, and 409.
- [ ] The tests pass with the Maven Wrapper (`.\mvnw.cmd test` on Windows, `sh ./mvnw test` elsewhere).
- [ ] `CHANGELOG.md` has an entry under `## [Unreleased]`.

## Out of scope

Refunds, restocking inventory, and any user interface.
