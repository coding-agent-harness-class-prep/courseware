# Orders service — instructions for Copilot

This is a Spring Boot 4 application on Java 21, built with the Maven Wrapper. Business rules live in the
`model`, `pricing`, `validation`, `catalog`, and `service` packages; `web` only maps HTTP to them. Money
is always `BigDecimal` with two decimal places — never `double`.

## Validation rules

- Every rule lives in `OrderValidator` and reports a `ValidationError`. Never throw for invalid input.
- Every new rule gets a new constant in `ValidationCodes`, numbered after the last one (`ORD006`,
  `ORD007`, …). Never reuse or renumber an existing code — API clients depend on them.
- Put a rule's limit in a named `public static final` on `OrderValidator` (for example
  `MAX_QUANTITY_PER_LINE`), never a bare number in the condition.
- A message is one user-facing sentence that names the SKU it's about and ends with a period.

## Tests

- Tests use JUnit 6 and AssertJ. Name them `method_scenario_expected`.
- For a limit, test both sides of the boundary in one `@ParameterizedTest` (`@CsvSource`): the last
  allowed value and the first rejected one.
- Assert on error **codes**, not on message text.

## Every change

- Add a line to `CHANGELOG.md` under `## [Unreleased]` describing the behavior change.
- Run the tests (`.\mvnw.cmd test` on Windows, `sh ./mvnw test` elsewhere) and make sure they pass before
  you say you're done.
