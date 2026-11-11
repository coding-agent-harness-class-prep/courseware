# Review guidelines for the Orders service

Check every pull request against these rules before anything else. When a change breaks one, leave a
comment that names the rule.

- Money is `BigDecimal`. Flag any `double` or `float` in pricing, discount, or tax arithmetic.
- `ValidationCodes` values are part of the public API. Flag a code that's renumbered, reused, or
  removed.
- Business rules belong in the `service`, `validation`, and `pricing` packages. Flag rule logic written
  inside a `@RestController`.
- A behavior change needs a `CHANGELOG.md` entry under `## [Unreleased]` and tests for every outcome
  it introduces, including error responses.
- Don't comment on import order or formatting.
