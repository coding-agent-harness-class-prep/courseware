#!/usr/bin/env bash
#
# build-all.sh — restore and build every project under courseware/ (macOS / Linux).
#
# Finds projects structurally, by the file that defines them:
#
#   *.slnx               .NET solution   restore: dotnet restore         build: dotnet build --no-restore
#   pom.xml + mvnw       Maven project   restore: mvnw dependency:resolve  build: mvnw -DskipTests package
#   package.json         npm project     restore: npm install            build: npm run build (if defined)
#
# Build output (bin, obj, target, node_modules, .git) is pruned from the walk, and the partial trees
# under demos/ and activities/ (assets/ and solution/ overlays) define no project.
#
# This is the sweep that makes a fresh clone, or a fresh VM image, ready to go: it downloads every
# package the course needs. It deliberately doesn't prove the samples BEHAVE — that's
# courseware/validations (`npm test`).
#
# Continue-on-error by design: one broken project must not hide the state of the others. Failures
# are collected, listed at the end, and the script exits 1.
#
# Usage:
#   ./build-all.sh                         # restore and build everything
#   ./build-all.sh --path 'samples/*-java' # only matching projects (quote the pattern)
#   ./build-all.sh --skip-install          # only build
#   ./build-all.sh --skip-build            # only restore
#   ./build-all.sh --force                 # reinstall npm projects even where node_modules exists
#   ./build-all.sh --list                  # print what would be processed, then exit
#
# Needs the tools for the projects it finds: the .NET SDK, a JDK (the Maven Wrapper fetches Maven),
# and Node.js. No container engine needed.
#
# To remove the build output this creates:  cd ../validations && npm run clean
#
# Windows? Use build-all.ps1 in this folder instead.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # courseware/utils
COURSEWARE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"               # courseware

FILTER=""
SKIP_INSTALL=0
SKIP_BUILD=0
FORCE=0
LIST_ONLY=0

usage() {
    cat <<'EOF'
build-all.sh — restore and build every project under courseware/

  --path <pattern>   only projects whose courseware-relative path matches (quote it)
  --skip-install     don't restore; only build
  --skip-build       don't build; only restore
  --force            run npm install even where node_modules already exists
  --list             print the projects that would be processed, then exit
  -h, --help         show this help

Exits 1 if any project failed. Cleanup lives in ../validations (npm run clean).
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --path)
            if [ $# -lt 2 ] || [ -z "${2:-}" ]; then
                echo "ERROR: --path needs a pattern, e.g. --path 'samples/*-java'." >&2
                exit 1
            fi
            FILTER="$2"; shift 2 ;;
        --skip-install) SKIP_INSTALL=1; shift ;;
        --skip-build)   SKIP_BUILD=1;   shift ;;
        --force)        FORCE=1;        shift ;;
        --list)         LIST_ONLY=1;    shift ;;
        -h|--help)      usage; exit 0 ;;
        *)
            echo "ERROR: unknown option '$1' (try --help)." >&2
            exit 1 ;;
    esac
done

# ---- discover ------------------------------------------------------------------------------------
# Each line of PROJECTS is "<kind> <courseware-relative path>".
PROJECTS=()

kind_of() {
    local dir="$1"
    if compgen -G "$dir/*.slnx" > /dev/null; then echo dotnet; return; fi
    if [ -f "$dir/pom.xml" ] && [ -f "$dir/mvnw" ]; then echo maven; return; fi
    if [ -f "$dir/package.json" ]; then echo npm; return; fi
    echo ""
}

walk() {
    local dir="$1" kind sub name
    kind="$(kind_of "$dir")"
    if [ -n "$kind" ]; then
        PROJECTS+=("$kind ${dir#"$COURSEWARE_DIR"/}")
        return
    fi
    for sub in "$dir"/*/ "$dir"/.[!.]*/; do
        [ -d "$sub" ] || continue
        sub="${sub%/}"
        name="$(basename "$sub")"
        case "$name" in
            node_modules|.git|bin|obj|target|TestResults|.vs|.idea) continue ;;
        esac
        walk "$sub"
    done
}

walk "$COURSEWARE_DIR"

if [ -n "$FILTER" ]; then
    FILTERED=()
    for entry in "${PROJECTS[@]}"; do
        # shellcheck disable=SC2053  # the pattern is intentionally unquoted
        [[ "${entry#* }" == $FILTER ]] && FILTERED+=("$entry")
    done
    PROJECTS=("${FILTERED[@]+"${FILTERED[@]}"}")
fi

if [ "${#PROJECTS[@]}" -eq 0 ]; then
    echo "ERROR: no projects found under $COURSEWARE_DIR${FILTER:+ matching '$FILTER'}." >&2
    exit 1
fi

IFS=$'\n' PROJECTS=($(printf '%s\n' "${PROJECTS[@]}" | sort -k2)); unset IFS

if [ "$LIST_ONLY" -eq 1 ]; then
    echo "==> ${#PROJECTS[@]} project(s) under $COURSEWARE_DIR"
    for entry in "${PROJECTS[@]}"; do printf '      %-7s %s\n' "${entry%% *}" "${entry#* }"; done
    exit 0
fi

# Check for the tools the discovered projects need, before doing any work.
for entry in "${PROJECTS[@]}"; do
    case "${entry%% *}" in
        dotnet) tool=dotnet ;;
        maven)  tool=java ;;
        npm)    tool=npm ;;
    esac
    if ! command -v "$tool" > /dev/null 2>&1; then
        echo "ERROR: '$tool' was not found on PATH, and ${entry%% *} projects need it. See ../setup/README.md." >&2
        exit 1
    fi
done

# Run a command, retrying once: restores fail transiently often enough to matter (dropped wifi,
# a momentary lock), and a genuinely broken project fails both attempts and is still reported.
with_retry() {
    local attempt
    for attempt in 1 2; do
        if "$@"; then return 0; fi
        if [ "$attempt" -eq 1 ]; then
            echo "         restore : failed -- retrying once (transient?)"
            sleep 3
        fi
    done
    return 1
}

has_build_script() {
    node -e 'const s=require(process.argv[1]).scripts||{}; process.exit(s.build&&String(s.build).trim()?0:1)' \
        "$1/package.json" 2> /dev/null
}

RESTORED=0
SKIPPED=0
BUILT=0
NO_BUILD=0
FAILURES=()
TOTAL=${#PROJECTS[@]}
INDEX=0
START=$(date +%s)

echo "==> Sweeping $TOTAL project(s) under $COURSEWARE_DIR"
[ "$SKIP_INSTALL" -eq 1 ] && echo "    (--skip-install: not restoring)"
[ "$SKIP_BUILD" -eq 1 ]   && echo "    (--skip-build: not building)"
[ "$FORCE" -eq 1 ]        && echo "    (--force: reinstalling npm projects even where node_modules exists)"
echo ""

for entry in "${PROJECTS[@]}"; do
    INDEX=$((INDEX + 1))
    kind="${entry%% *}"
    name="${entry#* }"
    dir="$COURSEWARE_DIR/$name"
    printf '[%2d/%d] %s (%s)\n' "$INDEX" "$TOTAL" "$name" "$kind"

    # ---- restore ---------------------------------------------------------------------------------
    if [ "$SKIP_INSTALL" -eq 0 ]; then
        if [ "$kind" = npm ] && [ "$FORCE" -eq 0 ] && [ -d "$dir/node_modules" ]; then
            echo "         restore : skipped (node_modules already present; --force to reinstall)"
            SKIPPED=$((SKIPPED + 1))
        else
            case "$kind" in
                dotnet) echo "         restore : dotnet restore ..."
                        cmd=(dotnet restore --verbosity quiet) ;;
                maven)  echo "         restore : mvnw dependency:resolve ..."
                        cmd=(sh ./mvnw -B -q dependency:resolve) ;;
                npm)    echo "         restore : npm install ..."
                        cmd=(npm install --no-audit --no-fund --loglevel=error) ;;
            esac
            if ! (cd "$dir" && with_retry "${cmd[@]}"); then
                echo "         restore : FAILED (after 2 attempts)"
                FAILURES+=("$name - restore (after 2 attempts)")
                continue
            fi
            echo "         restore : ok"
            RESTORED=$((RESTORED + 1))
        fi
    fi

    # ---- build -----------------------------------------------------------------------------------
    if [ "$SKIP_BUILD" -eq 0 ]; then
        if [ "$kind" = npm ] && ! has_build_script "$dir"; then
            echo '         build   : none (no "build" script in package.json)'
            NO_BUILD=$((NO_BUILD + 1))
            continue
        fi
        case "$kind" in
            dotnet) echo "         build   : dotnet build ..."
                    cmd=(dotnet build --no-restore --verbosity quiet --nologo) ;;
            maven)  echo "         build   : mvnw -DskipTests package ..."
                    cmd=(sh ./mvnw -B -q -DskipTests package) ;;
            npm)    echo "         build   : npm run build ..."
                    cmd=(npm run build) ;;
        esac
        if ! (cd "$dir" && "${cmd[@]}"); then
            echo "         build   : FAILED"
            FAILURES+=("$name - build")
            continue
        fi
        echo "         build   : ok"
        BUILT=$((BUILT + 1))
    fi
done

ELAPSED=$(( $(date +%s) - START ))

echo ""
echo "==> Summary"
echo "      projects : $TOTAL"
echo "      restored : $RESTORED  ($SKIPPED skipped - npm project already had node_modules)"
echo "      built    : $BUILT  ($NO_BUILD had nothing to build)"
echo "      failed   : ${#FAILURES[@]}"
echo "      elapsed  : ${ELAPSED}s"

if [ "${#FAILURES[@]}" -gt 0 ]; then
    echo ""
    echo "==> Failures"
    for f in "${FAILURES[@]}"; do echo "      $f"; done
    echo ""
    echo "ERROR: ${#FAILURES[@]} project(s) failed. See the list above." >&2
    exit 1
fi

echo ""
echo "==> All good. Next, prove the samples behave as the course says:"
echo "      cd ../validations && npm ci && npm test"
