# Review guidelines for the Orders service

Check every pull request against these rules before anything else. When a change breaks one, leave a
comment that names the rule.

- Money is `decimal`. Flag any `double` or `float` in pricing, discount, or tax arithmetic.
- `ValidationCodes` values are part of the public API. Flag a code that's renumbered, reused, or
  removed.
- Business rules belong in `src/Orders.Domain`. Flag rule logic written inside `Program.cs` endpoints.
- A behavior change needs a `CHANGELOG.md` entry under `## [Unreleased]` and tests for every outcome
  it introduces, including error responses.
- Don't comment on formatting that `.editorconfig` already covers.
