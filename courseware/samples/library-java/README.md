# Library lending service (Java)

A small lending API for a public library: books, members, loans, due dates, and late fees.
It's a Spring Boot 4 web application on Java 21 with an in-memory store, so there's no database to set up.

## Layout

```
pom.xml                          # Spring Boot parent pins every dependency version
mvnw, mvnw.cmd, .mvn/            # Maven Wrapper — no Maven install needed
src/main/java/com/example/library/
  model/        # Book, Member, Loan, MemberType
  lending/      # LoanService, LoanPolicy, DueDateCalculator, LibraryCalendar, the stores
  fees/         # LateFeeCalculator
  web/          # the REST controller
src/test/java/com/example/library/   # JUnit 6 tests, including MockMvc endpoint tests
```

## Build, test, run

```powershell
.\mvnw.cmd test                  # Windows
.\mvnw.cmd spring-boot:run       # http://localhost:8090
```

```bash
./mvnw test                      # macOS / Linux
./mvnw spring-boot:run
```

The wrapper downloads the pinned Maven version on first use; all it needs is a JDK 21 or later.

## Endpoints

| Method | Path | What it does |
|---|---|---|
| `GET` | `/books` | The catalog |
| `GET` | `/members/{id}` | A member, including outstanding fines |
| `POST` | `/loans` | Borrow a book (`{ "memberId", "isbn" }`): 201, 400 with policy codes, or 404 |
| `GET` | `/loans/{id}` | One loan, or 404 |
| `POST` | `/loans/{id}/return` | Return a book; any late fee is added to the member's fines |

## Lending rules in brief

Adults and seniors borrow for 14 days and students for 21. A loan is never due on a day the library is
closed (Sundays and public holidays). Late fees follow board policy LIB-12, in `LateFeeCalculator`.
