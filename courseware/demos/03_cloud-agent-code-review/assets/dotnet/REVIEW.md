# Review guidelines for the Library lending service

Check every pull request against these rules before anything else. When a change breaks one, leave a
comment that names the rule.

- Money is `decimal`. Flag any `double` or `float` in fee or fine arithmetic.
- "Today" comes from the injected `TimeProvider`. Flag `DateTime.Now`, `DateTime.Today`, or
  `DateOnly.FromDateTime(DateTime.Now)` anywhere under `src/`.
- `PolicyCodes` values are part of the public API. Flag a code that's renumbered, reused, or removed.
- A behavior change needs a `CHANGELOG.md` entry under `## [Unreleased]`, and a new limit needs a test
  on each side of it.
- Late fees must go through `LateFeeCalculator` (board policy LIB-12). Flag fee math done anywhere else.
- Don't comment on formatting that `.editorconfig` already covers.
