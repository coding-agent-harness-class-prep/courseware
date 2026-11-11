Circulation staff start each morning by phoning members whose books are overdue. Right now they export
every loan and filter it in a spreadsheet. Give them an endpoint that does it for them.

## What to build

`GET /loans/overdue` returns the **active** loans whose due date is before today, most overdue first.
Each item has:

| Field | Meaning |
|---|---|
| `loanId`, `isbn`, `memberId`, `dueOn` | From the loan |
| `daysOverdue` | Whole days between `dueOn` and today |
| `feeIfReturnedToday` | What `LateFeeCalculator` would charge if the book came back today |

Returned loans never appear. When nothing is overdue, return **200 OK** with an empty list.

## Where it goes

- Add the query to `LoanService` (`src/main/java/com/example/library/lending/LoanService.java`). Read
  "today" from the injected `Clock`, and reuse `LateFeeCalculator` (board policy LIB-12) rather than
  working the fee out again.
- Map the endpoint in `LibraryController` next to the other `/loans` endpoints.

## Acceptance criteria

- [ ] Plain JUnit tests (using `MutableClock`) cover: nothing overdue; one overdue loan's days and fee;
      and the ordering, with a returned loan left out.
- [ ] `sh ./mvnw test` passes.
- [ ] `CHANGELOG.md` has an entry under `## [Unreleased]`.
