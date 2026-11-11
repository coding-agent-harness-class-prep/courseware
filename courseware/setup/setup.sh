#!/usr/bin/env bash
#
# setup.sh — set up a macOS or Linux machine for
#            "GitHub Copilot as a Coding-Agent Harness".
#
# Installs what this course needs:
#
#   Visual Studio Code   macOS: brew --cask visual-studio-code    Linux: packages.microsoft.com apt repo
#   Git                  macOS: brew install git                  Linux: apt-get install git
#   GitHub CLI (gh)      macOS: brew install gh                   Linux: cli.github.com apt repo
#   GitHub Copilot CLI   macOS: brew --cask copilot-cli           Linux: the official install script (gh.io/copilot-install)
#   .NET 10 SDK          macOS: brew --cask dotnet-sdk            Linux: dotnet-sdk-10.0 (Ubuntu feed, backports PPA, or Microsoft feed)
#   JDK 21               macOS: brew --cask temurin@21            Linux: openjdk-21-jdk, or temurin-21-jdk from Adoptium
#
# ...then adds the VS Code extensions the labs use (C# Dev Kit, the Extension Pack for Java, GitHub
# Pull Requests). GitHub Copilot Chat is built into VS Code, so there's no Copilot extension to install.
#
# Safe to run more than once: anything already installed is reported and skipped.
# Nothing is skipped silently - a real failure is collected and the script exits 1.
#
# Usage:
#   ./setup.sh                    # install everything, then verify
#   ./setup.sh --skip-extensions  # applications only, no VS Code extensions
#   ./setup.sh --verify-only      # install nothing, just report what is here
#   ./setup.sh --dry-run          # print the commands, run none of them
#   ./setup.sh --help
#
# Windows? Use setup.ps1 in this folder instead - it is the supported path for this course.
#
# Exit codes
#   0  everything installed and verified
#   1  something genuinely failed (see the Failures list)
#   3  installed fine, but you must open a NEW terminal before every tool is on PATH
#      (for example the Copilot CLI in ~/.local/bin) - then re-run to verify.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKIP_EXTENSIONS=0
VERIFY_ONLY=0
DRY_RUN=0

FAILURES=()
WARNINGS=()
MISSING=()
RESTART_NEEDED=0

EXTENSIONS=(ms-dotnettools.csdevkit vscjava.vscode-java-pack github.vscode-pull-request-github)

usage() {
    cat <<'EOF'
setup.sh — set up a macOS or Linux machine for
           "GitHub Copilot as a Coding-Agent Harness"

  --skip-extensions  install the applications only; no VS Code extensions
  --verify-only      install nothing, just report what is already here
  --dry-run          print the commands without running them
  -h, --help         show this help

Windows users: run setup.ps1 in this folder instead.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --skip-extensions) SKIP_EXTENSIONS=1; shift ;;
        --verify-only)     VERIFY_ONLY=1;     shift ;;
        --dry-run)         DRY_RUN=1;         shift ;;
        -h|--help)         usage; exit 0 ;;
        *) echo "ERROR: unknown option '$1' (try --help)." >&2; exit 1 ;;
    esac
done

fail() {
    FAILURES+=("$1")
    echo "      FAILED: $1" >&2
}

warn() {
    WARNINGS+=("$1")
    echo "      WARNING: $1" >&2
}

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "      DRY RUN: $*"
        return 0
    fi
    "$@"
}

as_root() {
    if [ -n "$SUDO" ]; then
        run sudo "$@"
    else
        run "$@"
    fi
}

manual_install_list() {
    echo "    Install these by hand instead (all are free):"
    echo "      Visual Studio Code ... https://code.visualstudio.com"
    echo "      Git .................. https://git-scm.com/downloads"
    echo "      GitHub CLI ........... https://cli.github.com"
    echo "      GitHub Copilot CLI ... https://github.com/github/copilot-cli"
    echo "      .NET 10 SDK .......... https://dotnet.microsoft.com/download/dotnet/10.0"
    echo "      JDK 21 ............... https://adoptium.net/temurin/releases/?version=21"
}

# ---------------------------------------------------------------------------
# Detect the platform
# ---------------------------------------------------------------------------

OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux)
        if command -v apt-get >/dev/null 2>&1; then
            PLATFORM="debian"
        else
            echo "ERROR: this script supports macOS (Homebrew) and Debian/Ubuntu (apt)." >&2
            echo "       Your Linux distribution does not have apt-get." >&2
            manual_install_list >&2
            exit 1
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "ERROR: this looks like Git Bash on Windows. Run setup.ps1 instead:" >&2
        echo "       powershell -ExecutionPolicy Bypass -File ./setup.ps1" >&2
        exit 1
        ;;
    *)
        echo "ERROR: unsupported operating system '$OS'." >&2
        manual_install_list >&2
        exit 1
        ;;
esac

SUDO=""
if [ "$PLATFORM" = "debian" ] && [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    elif [ "$VERIFY_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
        echo "ERROR: installing system packages needs root, and sudo is not available." >&2
        manual_install_list >&2
        exit 1
    fi
fi

# The Copilot CLI's install script puts the binary in ~/.local/bin for a non-root user.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) [ -x "$HOME/.local/bin/copilot" ] && export PATH="$HOME/.local/bin:$PATH" ;;
esac

# ---------------------------------------------------------------------------
# macOS
# ---------------------------------------------------------------------------

install_formula() {
    local token="$1" command_name="$2" label="$3"
    echo "==> $label"
    if command -v "$command_name" >/dev/null 2>&1; then
        echo "      already installed ($("$command_name" --version 2>&1 | head -n 1)) - skipping."
        return 0
    fi
    run brew install "$token" || fail "$label (brew install $token)"
}

install_cask() {
    local token="$1" present_test="$2" label="$3"
    echo "==> $label"
    if brew list --cask "$token" >/dev/null 2>&1; then
        echo "      already installed via Homebrew - skipping."
        return 0
    fi
    if eval "$present_test" >/dev/null 2>&1; then
        echo "      already installed (not via Homebrew) - skipping."
        return 0
    fi
    run brew install --cask "$token" || fail "$label (brew install --cask $token)"
}

# The dotnet-sdk cask tracks the newest .NET, so once a newer major version ships it no longer
# installs .NET 10. Check for a 10.x SDK by version, not by cask, and say so if the cask didn't
# provide one.
dotnet_sdk10_version() {
    # The installer's own path covers a fresh install that isn't on this shell's PATH yet.
    { dotnet --list-sdks 2>/dev/null || /usr/local/share/dotnet/dotnet --list-sdks 2>/dev/null; } \
        | grep '^10\.' | tail -n 1 | cut -d' ' -f1
}

install_dotnet_macos() {
    echo "==> .NET 10 SDK"
    if [ -n "$(dotnet_sdk10_version)" ]; then
        echo "      already installed ($(dotnet_sdk10_version)) - skipping."
        return 0
    fi
    if ! brew list --cask dotnet-sdk >/dev/null 2>&1; then
        run brew install --cask dotnet-sdk || { fail ".NET 10 SDK (brew install --cask dotnet-sdk)"; return; }
    fi
    [ "$DRY_RUN" -eq 1 ] && return 0
    if [ -z "$(dotnet_sdk10_version)" ]; then
        fail ".NET 10 SDK (Homebrew's dotnet-sdk cask installed a different version; install 10.0 from https://dotnet.microsoft.com/download/dotnet/10.0)"
    fi
}

setup_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "ERROR: Homebrew was not found." >&2
        echo "       Install it first (it will ask for your password):" >&2
        echo '         /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >&2
        echo "       Then open a new terminal and run this script again." >&2
        exit 1
    fi
    echo "==> Homebrew found ($(brew --version | head -n 1))"
    echo ""

    install_formula git git "Git"
    install_formula gh gh "GitHub CLI"
    install_cask visual-studio-code "test -d '/Applications/Visual Studio Code.app'" "Visual Studio Code"
    install_cask copilot-cli "command -v copilot" "GitHub Copilot CLI"
    install_dotnet_macos
    install_cask temurin@21 "/usr/libexec/java_home -v 21" "JDK 21 (Temurin)"
}

# ---------------------------------------------------------------------------
# Debian / Ubuntu
# ---------------------------------------------------------------------------

OS_ID=""
OS_VERSION=""
OS_CODENAME=""
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    OS_ID="$(. /etc/os-release && echo "${ID:-}")"
    OS_VERSION="$(. /etc/os-release && echo "${VERSION_ID:-}")"
    OS_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
fi

add_apt_key() {
    # add_apt_key <url> <keyring path> [dearmor]
    local url="$1" keyring="$2" dearmor="${3:-}"
    local tmpkey
    tmpkey="$(mktemp)"
    if [ -n "$dearmor" ]; then
        run sh -c "wget -qO- '$url' | gpg --dearmor > '$tmpkey'" || { fail "download signing key $url"; rm -f "$tmpkey"; return 1; }
    else
        run wget -qO "$tmpkey" "$url" || { fail "download signing key $url"; rm -f "$tmpkey"; return 1; }
    fi
    as_root install -D -o root -g root -m 644 "$tmpkey" "$keyring" || fail "install signing key $keyring"
    rm -f "$tmpkey"
}

add_apt_source() {
    # add_apt_source <file under /etc/apt/sources.list.d> <line(s)>
    local file="$1"; shift
    local tmpsrc
    tmpsrc="$(mktemp)"
    printf '%s\n' "$@" > "$tmpsrc"
    as_root install -D -o root -g root -m 644 "$tmpsrc" "/etc/apt/sources.list.d/$file" || fail "add apt source $file"
    rm -f "$tmpsrc"
}

setup_debian() {
    echo "==> Refreshing apt package lists"
    as_root apt-get update -qq || fail "apt-get update"

    echo "==> Base tools (git, curl, wget, gpg, ca-certificates)"
    as_root apt-get install -y git curl wget gpg ca-certificates apt-transport-https \
        || fail "apt-get install base tools"

    # ---- VS Code ----------------------------------------------------------
    echo "==> Visual Studio Code"
    if command -v code >/dev/null 2>&1; then
        echo "      already installed ($(code --version | head -n 1)) - skipping."
    else
        # https://code.visualstudio.com/docs/setup/linux
        add_apt_key https://packages.microsoft.com/keys/microsoft.asc /usr/share/keyrings/microsoft.gpg dearmor
        add_apt_source vscode.sources \
            'Types: deb' \
            'URIs: https://packages.microsoft.com/repos/code' \
            'Suites: stable' \
            'Components: main' \
            'Architectures: amd64,arm64,armhf' \
            'Signed-By: /usr/share/keyrings/microsoft.gpg'
        as_root apt-get update -qq || fail "apt-get update (after adding the VS Code source)"
        as_root apt-get install -y code || fail "apt-get install code"
    fi

    # ---- GitHub CLI -------------------------------------------------------
    echo "==> GitHub CLI"
    if command -v gh >/dev/null 2>&1; then
        echo "      already installed ($(gh --version | head -n 1)) - skipping."
    else
        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
        add_apt_key https://cli.github.com/packages/githubcli-archive-keyring.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg
        add_apt_source github-cli.list \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
        as_root apt-get update -qq || fail "apt-get update (after adding the GitHub CLI source)"
        as_root apt-get install -y gh || fail "apt-get install gh"
    fi

    # ---- .NET 10 SDK ------------------------------------------------------
    echo "==> .NET 10 SDK"
    if command -v dotnet >/dev/null 2>&1 && dotnet --list-sdks 2>/dev/null | grep -q '^10\.'; then
        echo "      already installed - skipping."
    else
        # https://learn.microsoft.com/dotnet/core/install/linux
        if [ "$OS_ID" = "debian" ]; then
            tmpdeb="$(mktemp --suffix=.deb)"
            if run wget -qO "$tmpdeb" "https://packages.microsoft.com/config/debian/${OS_VERSION%%.*}/packages-microsoft-prod.deb"; then
                as_root dpkg -i "$tmpdeb" || fail "register the Microsoft package feed"
            else
                fail "download the Microsoft package feed configuration for Debian $OS_VERSION"
            fi
            rm -f "$tmpdeb"
        elif [ "$OS_ID" = "ubuntu" ] && [ "$OS_VERSION" = "22.04" ]; then
            as_root apt-get install -y software-properties-common || fail "apt-get install software-properties-common"
            as_root add-apt-repository -y ppa:dotnet/backports || fail "add the .NET backports PPA"
        fi
        # Ubuntu 24.04 and later carry dotnet-sdk-10.0 in their own feed.
        as_root apt-get update -qq || fail "apt-get update (for .NET)"
        as_root apt-get install -y dotnet-sdk-10.0 || fail "apt-get install dotnet-sdk-10.0"
    fi

    # ---- JDK 21 -----------------------------------------------------------
    echo "==> JDK 21"
    if command -v java >/dev/null 2>&1 && [ "$(java_major)" -ge 21 ]; then
        echo "      already installed ($(java -version 2>&1 | head -n 1)) - skipping."
    elif apt-cache show openjdk-21-jdk >/dev/null 2>&1; then
        as_root apt-get install -y openjdk-21-jdk || fail "apt-get install openjdk-21-jdk"
    else
        # Debian 12 has no openjdk-21-jdk; use the Eclipse Adoptium repository.
        # https://adoptium.net/installation/linux/
        add_apt_key https://packages.adoptium.net/artifactory/api/gpg/key/public /etc/apt/keyrings/adoptium.gpg dearmor
        add_apt_source adoptium.list \
            "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $OS_CODENAME main"
        as_root apt-get update -qq || fail "apt-get update (after adding the Adoptium source)"
        as_root apt-get install -y temurin-21-jdk || fail "apt-get install temurin-21-jdk"
    fi

    # ---- GitHub Copilot CLI -----------------------------------------------
    echo "==> GitHub Copilot CLI"
    if command -v copilot >/dev/null 2>&1; then
        echo "      already installed ($(copilot --version 2>&1 | head -n 1)) - skipping."
    else
        # https://docs.github.com/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli
        # The script installs to ~/.local/bin for a non-root user, verifying the release checksum.
        tmpscript="$(mktemp)"
        if run curl -fsSL -o "$tmpscript" https://gh.io/copilot-install; then
            if run bash "$tmpscript"; then
                if ! command -v copilot >/dev/null 2>&1; then
                    if [ -x "$HOME/.local/bin/copilot" ]; then
                        export PATH="$HOME/.local/bin:$PATH"
                    fi
                    RESTART_NEEDED=1
                fi
            else
                fail "the Copilot CLI install script"
            fi
        else
            fail "download the Copilot CLI install script"
        fi
        rm -f "$tmpscript"
    fi
}

# ---------------------------------------------------------------------------
# VS Code extensions (same on both platforms)
# ---------------------------------------------------------------------------

install_extensions() {
    echo "==> VS Code extensions"
    if [ "$DRY_RUN" -eq 1 ]; then
        for ext in "${EXTENSIONS[@]}"; do echo "      DRY RUN: code --install-extension $ext"; done
        return 0
    fi
    if ! command -v code >/dev/null 2>&1; then
        warn "The 'code' command is not on PATH, so extensions weren't installed. Open VS Code, press Cmd+Shift+P / Ctrl+Shift+P, run \"Shell Command: Install 'code' command in PATH\", then re-run this script."
        return 0
    fi
    for ext in "${EXTENSIONS[@]}"; do
        echo "      $ext"
        code --install-extension "$ext" >/dev/null 2>&1 || fail "VS Code extension $ext"
    done
}

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

java_major() {
    # Prints the major version of `java` on PATH (0 if unknown).
    local line
    line="$(java -version 2>&1 | head -n 1 || true)"
    if [[ "$line" =~ version\ \"([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo 0
    fi
}

check_version() {
    local label="$1"
    shift
    if ! command -v "$1" >/dev/null 2>&1; then
        printf '      %-8s: NOT FOUND\n' "$label"
        MISSING+=("$label")
        return 0
    fi
    printf '      %-8s: %s\n' "$label" "$("$@" 2>&1 | head -n 1)"
}

verify() {
    echo ""
    echo "==> Verifying"
    MISSING=()

    check_version "code"    code    --version
    check_version "git"     git     --version
    check_version "gh"      gh      --version
    check_version "copilot" copilot --version

    if command -v dotnet >/dev/null 2>&1 && dotnet --list-sdks 2>/dev/null | grep -q '^10\.'; then
        printf '      %-8s: SDK %s\n' "dotnet" "$(dotnet --list-sdks | grep '^10\.' | tail -n 1 | cut -d' ' -f1)"
    else
        printf '      %-8s: no .NET 10 SDK found\n' "dotnet"
        MISSING+=(".NET 10 SDK")
    fi

    if command -v java >/dev/null 2>&1 && [ "$(java_major)" -ge 21 ]; then
        printf '      %-8s: %s\n' "java" "$(java -version 2>&1 | head -n 1)"
    else
        printf '      %-8s: no JDK 21 or later found\n' "java"
        MISSING+=("JDK 21")
    fi

    if [ "$SKIP_EXTENSIONS" -eq 0 ] && command -v code >/dev/null 2>&1; then
        installed="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"
        for ext in "${EXTENSIONS[@]}"; do
            if printf '%s\n' "$installed" | grep -qx "$ext"; then
                printf '      %-8s: %s\n' "ext" "$ext"
            else
                printf '      %-8s: %s NOT INSTALLED\n' "ext" "$ext"
                MISSING+=("$ext")
            fi
        done
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

echo "==> GitHub Copilot as a Coding-Agent Harness - $PLATFORM setup"
echo "    $SCRIPT_DIR/setup.sh"
[ "$DRY_RUN" -eq 1 ] && echo "    DRY RUN - nothing will actually be installed."
echo ""

if [ "$VERIFY_ONLY" -eq 1 ]; then
    verify
    echo ""
    if [ "${#MISSING[@]}" -gt 0 ]; then
        echo "==> Missing: ${MISSING[*]}"
        echo "    Run this script without --verify-only to install them."
        exit 1
    fi
    echo "==> Everything this course needs is installed."
    echo "    Next: sign in to GitHub in VS Code, and run 'copilot' then /login once."
    exit 0
fi

if [ "$PLATFORM" = "macos" ]; then
    setup_macos
else
    setup_debian
fi
echo ""

if [ "$SKIP_EXTENSIONS" -eq 1 ]; then
    echo "==> Skipping VS Code extensions (--skip-extensions)."
else
    install_extensions
fi
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    MISSING=()
else
    verify
    # Missing after a clean install usually means a PATH this terminal can't see yet.
    if [ "${#MISSING[@]}" -gt 0 ] && [ "${#FAILURES[@]}" -eq 0 ]; then
        RESTART_NEEDED=1
    fi
fi

echo ""
echo "==> Summary"
printf '      failed   : %d\n' "${#FAILURES[@]}"
printf '      warnings : %d\n' "${#WARNINGS[@]}"

if [ "${#WARNINGS[@]}" -gt 0 ]; then
    echo ""
    echo "==> Warnings"
    for w in "${WARNINGS[@]}"; do
        echo "      $w"
    done
fi

if [ "${#FAILURES[@]}" -gt 0 ]; then
    echo ""
    echo "==> Failures"
    for f in "${FAILURES[@]}"; do
        echo "      $f"
    done
    echo ""
    manual_install_list
    echo ""
    echo "ERROR: ${#FAILURES[@]} step(s) failed. See the list above." >&2
    exit 1
fi

if [ "$RESTART_NEEDED" -eq 1 ]; then
    echo ""
    echo "==> ACTION REQUIRED - open a NEW terminal"
    echo ""
    if [ "${#MISSING[@]}" -gt 0 ]; then
        echo "    Not visible in this terminal yet: ${MISSING[*]}"
    fi
    echo "    New installs add themselves to PATH (the Copilot CLI uses ~/.local/bin, the .NET"
    echo "    SDK cask uses /etc/paths.d), and a terminal that was already open cannot see that."
    echo ""
    echo "      1. Close this terminal and open a new one."
    echo "      2. Check it worked:  ./setup.sh --verify-only"
    echo ""
    echo "    Nothing is broken - this is just how shell profiles work."
    echo ""
    exit 3
fi

echo ""
echo "==> You are ready. Next:"
echo "      1. Open VS Code and sign in to GitHub (the Copilot icon in the Status Bar)."
echo "      2. Run 'copilot', then /login, to sign the Copilot CLI in."
echo "      3. Optional, to download every package ahead of class:"
echo "           cd ../utils && ./build-all.sh"
