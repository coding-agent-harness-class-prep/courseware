# Library lending service — instructions for Copilot

This is a Spring Boot 4 application on Java 21, built with the Maven Wrapper. Business rules live in the
`model`, `lending`, and `fees` packages; `web` only maps HTTP to them. Money is always `BigDecimal` with
two decimal places, and "today" comes from the injected `Clock` — never `LocalDate.now()` with no
argument.

## Loan rules

- Every borrowing rule lives in `LoanPolicy.canBorrow` and reports a `PolicyViolation`. Never throw.
- Every new rule gets a new constant in `PolicyCodes`, numbered after the last one (`LIB003`, `LIB004`,
  …). Never reuse or renumber an existing code.
- Put a rule's limit in a named `public static final` on `LoanPolicy` (for example
  `MAX_OUTSTANDING_FINES`).
- A violation message is one sentence, addressed to library staff, that names the member or the book.

## Tests

- Tests use JUnit 6 and AssertJ. Name them `method_scenario_expected`.
- Test both sides of every limit in one `@ParameterizedTest` (`@CsvSource`): the last allowed value and
  the first rejected one.
- Assert on violation **codes**, not on message text.

## Every change

- Add a line to `CHANGELOG.md` under `## [Unreleased]`.
- Run the tests (`.\mvnw.cmd test` on Windows, `sh ./mvnw test` elsewhere) and make sure they pass before
  you say you're done.
