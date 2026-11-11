# Review guidelines for the Library lending service

Check every pull request against these rules before anything else. When a change breaks one, leave a
comment that names the rule.

- Money is `BigDecimal`. Flag any `double` or `float` in fee or fine arithmetic.
- "Today" comes from the injected `Clock`. Flag `LocalDate.now()` or `Instant.now()` called
  without the clock anywhere under `src/main/`.
- `PolicyCodes` values are part of the public API. Flag a code that's renumbered, reused, or removed.
- A behavior change needs a `CHANGELOG.md` entry under `## [Unreleased]`, and a new limit needs a test
  on each side of it.
- Late fees must go through `LateFeeCalculator` (board policy LIB-12). Flag fee math done anywhere else.
- Don't comment on import order or formatting.
