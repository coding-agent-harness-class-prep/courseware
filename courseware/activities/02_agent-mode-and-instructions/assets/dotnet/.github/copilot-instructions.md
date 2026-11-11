# Orders service — instructions for Copilot

This is an ASP.NET Core minimal API on .NET 10. Business rules live in `src/Orders.Domain` and have no
web dependencies; `src/Orders.Api/Program.cs` only maps HTTP to the domain. Money is always `decimal`.

## Validation rules

- Every rule lives in `OrderValidator` and reports a `ValidationError`. Never throw for invalid input.
- Every new rule gets a new constant in `ValidationCodes`, numbered after the last one (`ORD006`,
  `ORD007`, …). Never reuse or renumber an existing code — API clients depend on them.
- Put a rule's limit in a named `public const` on `OrderValidator` (for example `MaxQuantityPerLine`),
  never a bare number in the condition.
- A message is one user-facing sentence that names the SKU it's about and ends with a period.

## Tests

- Tests use xUnit v3 (`[Fact]`, `[Theory]` with `[InlineData]`). Name them `Method_Scenario_Expected`.
- For a limit, test both sides of the boundary in one `[Theory]`: the last allowed value and the first
  rejected one.
- Assert on error **codes**, not on message text.
- The build treats warnings as errors, xUnit's analyzers included: use `Assert.Empty` or `Assert.Single`
  rather than comparing a count, and pass `TestContext.Current.CancellationToken` to async calls.

## Every change

- Add a line to `CHANGELOG.md` under `## [Unreleased]` describing the behavior change.
- Run `dotnet test` and make sure it passes before you say you're done.
