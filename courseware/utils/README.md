# Course-wide build utilities

These scripts **restore and build every project in the courseware** in a single command, so a fresh
clone, or a fresh student VM image, has every NuGet package, Maven artifact, and npm module the course
needs before anyone asks for it. Unlike the `slides/` and `outline/` toolchains, they don't need a
container engine.

| Script | Platform |
|---|---|
| [`build-all.ps1`](build-all.ps1) | Windows, PowerShell 7+ |
| [`build-all.sh`](build-all.sh) | macOS / Linux (also runs in Git Bash) |

## What it finds

Projects are discovered **structurally**, by the file that defines them, so there's no list to keep up
to date. Today that's five:

| Kind | Found by | Restore | Build |
|---|---|---|---|
| .NET | a `*.slnx` file | `dotnet restore` | `dotnet build --no-restore` |
| Maven | `pom.xml` next to the Maven Wrapper | `mvnw dependency:resolve` | `mvnw -DskipTests package` |
| npm | `package.json` | `npm install` (skipped if `node_modules` exists, unless forced) | `npm run build`, if the project defines one |

That's `samples/library-dotnet`, `samples/library-java`, `samples/orders-dotnet`,
`samples/orders-java`, and the `validations` harness. The `assets/` and `solution/` folders under
`demos/` and `activities/` are partial trees that overlay a sample, so they define no project of their
own and aren't picked up.

## Usage

```powershell
.\build-all.ps1                        # restore and build everything
.\build-all.ps1 -List                  # show what it would process
.\build-all.ps1 -Path 'samples/*-java' # only matching projects
.\build-all.ps1 -Path 'samples/*'      # just the samples (a student VM has no Node.js)
.\build-all.ps1 -SkipBuild             # restore only (a quick cache warm-up)
.\build-all.ps1 -Force                 # reinstall npm projects too
```

```bash
./build-all.sh --list
./build-all.sh --path 'samples/*-dotnet' --skip-build
```

It continues past a failing project, retries a failed restore once (classroom and conference networks
drop connections), and exits non-zero with a list of failures at the end.

## How it differs from `validations/`

This sweep proves every project **restores and compiles**. It doesn't run any tests. The
[`validations/`](../validations/README.md) harness proves the samples **behave as the course says**: each
sample's tests pass, each reference solution passes, and each planted bug's repro test fails for the
reason its issue describes. Run this first on a new machine, then `npm test` in `validations/`.

To remove the build output (`bin/`, `obj/`, `target/`), use the harness: `cd ..\validations; npm run clean`.
