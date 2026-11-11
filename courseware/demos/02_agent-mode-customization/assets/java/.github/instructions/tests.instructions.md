---
applyTo: "src/test/**"
---

# Writing tests in this repository

- Use the real stores (`BookCatalog`, `MemberDirectory`, `LoanRepository`) instead of Mockito mocks
  for domain tests.
- Control "today" with the `MutableClock` test helper; never depend on the real date.
- Plain JUnit tests for the domain packages; reserve `@SpringBootTest` + MockMvc for the `web`
  controller, because it starts the whole application and is slow.
- One behavior per test. If a test needs the word "and" in its name, split it.
