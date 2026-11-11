The reporting team imports a file of each member's loan history every night. Their importer is built on
JSON-java (`org.json`), and they've asked for the export to be written with the same library at the same
version, so dates and nulls come out exactly the way their importer reads them.

## What to build

`GET /members/{id}/loans/export` returns every loan the member has had, active and returned, oldest
first, as a JSON array. Each item has:

| Field | Meaning |
|---|---|
| `loanId`, `isbn`, `borrowedOn`, `dueOn` | From the loan |
| `returnedOn` | The return date, or `null` while the book is still out |

An unknown member returns **404 Not Found**. A member with no loans gets **200 OK** and an empty array.

## Where it goes

- Add a query to `LoanService` (`src/main/java/com/example/library/lending/LoanService.java`) that
  returns one member's loans. Check what `LoanRepository` already offers before you add to it.
- Map the endpoint in `LibraryController` next to `GET /members/{id}`, and build the response with
  **org.json 20230227** (`org.json:json`), the version the reporting importer pins.
- Add the dependency to `pom.xml` at exactly that version.

## Acceptance criteria

- [ ] Tests in `LibraryControllerTest` cover: an unknown member; a member with no loans; and a member
      with one returned and one active loan, oldest first.
- [ ] `sh ./mvnw test` passes.
- [ ] `CHANGELOG.md` has an entry under `## [Unreleased]`.
