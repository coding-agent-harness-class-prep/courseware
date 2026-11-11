---
applyTo: "src/test/**"
---

# Writing tests in this repository

- Use the real in-memory implementations (`InMemoryProductCatalog`, `InMemoryOrderRepository`) instead
  of Mockito mocks for domain tests.
- Plain JUnit tests for the domain packages; reserve `@SpringBootTest` + MockMvc for tests of the `web`
  controllers, because they start the whole application and are slow.
- One behavior per test. If a test needs the word "and" in its name, split it.
- Prefer AssertJ (`assertThat(...)`, `extracting(...)`, `singleElement()`) over JUnit's `assertEquals`.
