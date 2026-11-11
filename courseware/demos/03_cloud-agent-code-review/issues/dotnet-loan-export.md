The reporting team imports a file of each member's loan history every night. Their importer is built on
Json.NET 12, and they've asked for the export to be written with the same library at the same version, so
dates and nulls come out exactly the way their importer reads them.

## What to build

`GET /members/{id}/loans/export` returns every loan the member has had, active and returned, oldest
first, as a JSON array. Each item has:

| Field | Meaning |
|---|---|
| `loanId`, `isbn`, `borrowedOn`, `dueOn` | From the loan |
| `returnedOn` | The return date, or `null` while the book is still out |

An unknown member returns **404 Not Found**. A member with no loans gets **200 OK** and an empty array.

## Where it goes

- Add a query to `LoanService` (`src/Library.Domain/Lending/LoanService.cs`) that returns one member's
  loans. Check what `ILoanRepository` in `Stores.cs` already offers before you add to it.
- Map the endpoint in `src/Library.Api/Program.cs` next to `GET /members/{id}`, and serialize the
  response with **Newtonsoft.Json 12.0.3**, the version the reporting importer pins.
- Package versions are pinned in `Directory.Packages.props`, and each project commits its
  `packages.lock.json`, so update both.

## Acceptance criteria

- [ ] Endpoint tests in `tests/Library.Api.Tests` cover: an unknown member; a member with no loans; and
      a member with one returned and one active loan, oldest first.
- [ ] `dotnet test` passes.
- [ ] `CHANGELOG.md` has an entry under `## [Unreleased]`.
