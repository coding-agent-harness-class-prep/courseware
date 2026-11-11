# Courseware validations

This harness, run by instructors and by CI, proves the course's code and slides do what the course says
they do. Run it after changing a sample, a demo or activity overlay, a deck, or a diagram:

```powershell
cd courseware\validations
npm ci
npm test
```

It needs Node.js (CI uses 24), the .NET 10 SDK, and a JDK 21 or later on the machine (the Maven Wrapper fetches
Maven). The first run downloads every NuGet and Maven package; later runs reuse the caches. CI runs the
same thing on every push and pull request (`.github/workflows/validate-courseware.yml`).

## What it checks

| Spec | Command | What it proves |
|---|---|---|
| [`unit/samples.test.js`](unit/samples.test.js) | `npm run test:samples` | Every scenario in [`lib/manifest.js`](lib/manifest.js): each sample's own tests pass; each demo and activity `solution/` passes when laid over its sample; and each planted bug's repro test **fails, and fails only on the test it's named for** |
| [`unit/slides.test.js`](unit/slides.test.js) | `npm run test:slides` | No slide in the committed `slides/pdf/` decks is clipped, every page matches its Markdown heading, and every diagram a deck embeds exists |
| [`unit/links.test.js`](unit/links.test.js) | `npm run test:links` | Every relative link and image in every Markdown file resolves, and every diagram exists as `svg`, `png`, and `pdf` |

## How a sample scenario runs

Each scenario names a sample and a list of overlay folders. The harness copies the sample to a fresh
temporary folder (leaving out `bin/`, `obj/`, and `target/`), copies each overlay on top (overlays
mirror the sample's own paths), and runs the sample's real test command: `dotnet test` for .NET, and
the Maven Wrapper (`mvnw.cmd test` on Windows, `sh ./mvnw test` elsewhere) for Java. That's exactly what
a student does in class.

An `expect: 'fail'` scenario is the important one. The Module 4 repro tests are only useful if they
fail for the right reason, so the harness reads the failing test names out of the output and requires
every one of them to match the scenario's `failingTest` pattern.

## Adding something

Adding a demo or activity that ships code means adding its scenarios to `lib/manifest.js`, a few lines
each. You don't write new test files.

## Cleaning up

```powershell
npm run clean
```

removes build output (`bin/`, `obj/`, `target/`, `TestResults/`) under `courseware/samples/` and any
temporary workspaces left by an interrupted run. It never deletes a git-tracked file.
