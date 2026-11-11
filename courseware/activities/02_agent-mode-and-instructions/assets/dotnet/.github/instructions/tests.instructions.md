---
applyTo: "tests/**"
---

# Writing tests in this repository

- Use the real in-memory implementations (`InMemoryProductCatalog`, `InMemoryOrderRepository`) instead
  of mocks. There's no mocking library in this solution, and we don't want one.
- Build requests from a small valid baseline and change one thing with a `with` expression, the way
  `OrderValidatorTests.ValidRequest()` does.
- One behavior per test. If a test needs the word "and" in its name, split it.
- Endpoint tests go in `tests/Orders.Api.Tests` and use `WebApplicationFactory<Program>`; everything
  else goes in `tests/Orders.Domain.Tests`.
