<#
.SYNOPSIS
    Set up a Windows machine for "GitHub Copilot as a Coding-Agent Harness".

.DESCRIPTION
    Installs what this course needs, using winget:

        Visual Studio Code ........... Microsoft.VisualStudioCode
        Git .......................... Git.Git
        GitHub CLI ................... GitHub.cli
        PowerShell 7 ................. Microsoft.PowerShell   (the Copilot CLI needs PowerShell 6+)
        GitHub Copilot CLI ........... GitHub.Copilot
        .NET 10 SDK .................. Microsoft.DotNet.SDK.10
        JDK 21 (Eclipse Temurin) ..... EclipseAdoptium.Temurin.21.JDK

    ...then adds the VS Code extensions the labs use (C# Dev Kit, the Extension Pack for Java, and
    GitHub Pull Requests), and finally prints the version of everything so you can see that it
    worked. GitHub Copilot Chat is built into VS Code, so there's no Copilot extension to install.

    Safe to run more than once. A package that is already installed and current is reported as
    such and skipped - winget signals that with a non-zero exit code (0x8A15002B / 0x8A15010D),
    which this script treats as success rather than an error. Anything that genuinely fails is
    collected and the script exits 1.

    This is the bootstrap script, so it is written to run on Windows PowerShell 5.1 (what a fresh
    Windows image ships with) as well as PowerShell 7+. Please keep it free of 7-only syntax, and
    keep its console output pure ASCII.

.PARAMETER SkipExtensions
    Install the applications only; don't add VS Code extensions.

.PARAMETER VerifyOnly
    Install nothing. Just report what is already on this machine.

.PARAMETER DryRun
    Print every command that would run, without running any of them.

.EXAMPLE
    # From courseware\setup, in a PowerShell window:
    powershell -ExecutionPolicy Bypass -File .\setup.ps1

.EXAMPLE
    .\setup.ps1 -DryRun
    .\setup.ps1 -VerifyOnly
    .\setup.ps1 -SkipExtensions

.NOTES
    Exit codes
      0  everything installed and verified
      1  something genuinely failed (see the Failures list)
      3  installed fine, but you must close this terminal and open a NEW one before the new
         tools are on PATH. Installers write PATH to the registry, and a shell that was already
         running can't always see the change. Re-run then.

    winget return codes: https://github.com/microsoft/winget-cli/blob/master/doc/windows/package-manager/winget/returnCodes.md
#>
param(
    [switch]$SkipExtensions,
    [switch]$VerifyOnly,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# PowerShell 7.4+ turns a non-zero native exit code into a terminating error when
# $ErrorActionPreference is 'Stop'. winget uses non-zero codes to mean "already
# installed", so we inspect $LASTEXITCODE ourselves. (Harmless no-op on 5.1.)
$PSNativeCommandUseErrorActionPreference = $false

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# winget exit codes that are NOT failures.
$WingetNoUpgrade        = [Convert]::ToUInt32('8A15002B', 16)  # UPDATE_NOT_APPLICABLE
$WingetAlreadyInstalled = [Convert]::ToUInt32('8A15010D', 16)  # INSTALL_ALREADY_INSTALLED
# ...and the ones that mean "installed, but Windows wants a reboot".
$WingetRebootToFinish   = [Convert]::ToUInt32('8A150109', 16)
$WingetRebootRequired   = [Convert]::ToUInt32('8A15010A', 16)
$WingetRebootInitiated  = [Convert]::ToUInt32('8A15010B', 16)

$Failures      = New-Object System.Collections.ArrayList
$Warnings      = New-Object System.Collections.ArrayList
$RestartNeeded = $false

$Apps = @(
    @{ Name = 'Visual Studio Code'; Id = 'Microsoft.VisualStudioCode' },
    @{ Name = 'Git';                Id = 'Git.Git' },
    @{ Name = 'GitHub CLI';         Id = 'GitHub.cli' },
    @{ Name = 'PowerShell 7';       Id = 'Microsoft.PowerShell' },
    @{ Name = 'GitHub Copilot CLI'; Id = 'GitHub.Copilot' },
    @{ Name = '.NET 10 SDK';        Id = 'Microsoft.DotNet.SDK.10' },
    @{ Name = 'JDK 21 (Temurin)';   Id = 'EclipseAdoptium.Temurin.21.JDK' }
)

$Extensions = @(
    @{ Name = 'C# Dev Kit';             Id = 'ms-dotnettools.csdevkit' },
    @{ Name = 'Extension Pack for Java'; Id = 'vscjava.vscode-java-pack' },
    @{ Name = 'GitHub Pull Requests';   Id = 'github.vscode-pull-request-github' }
)

function Show-ManualInstallList {
    Write-Host '    Install these by hand instead (all are free):'
    Write-Host '      Visual Studio Code ... https://code.visualstudio.com'
    Write-Host '      Git for Windows ...... https://git-scm.com/download/win'
    Write-Host '      GitHub CLI ........... https://cli.github.com'
    Write-Host '      PowerShell 7 ......... https://aka.ms/powershell'
    Write-Host '      GitHub Copilot CLI ... https://github.com/github/copilot-cli'
    Write-Host '      .NET 10 SDK .......... https://dotnet.microsoft.com/download/dotnet/10.0'
    Write-Host '      JDK 21 ............... https://adoptium.net/temurin/releases/?version=21'
}

function Assert-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $version = (& winget --version 2>&1 | Select-Object -First 1)
        Write-Host "==> winget found ($version)"
        return
    }

    Write-Host ''
    Write-Host 'ERROR: winget (the Windows Package Manager) was not found.'
    Write-Host ''
    Write-Host '    winget ships with Windows 11 and with recent Windows 10 builds as part of'
    Write-Host '    "App Installer". Older or freshly-imaged Windows 10 machines may not have it.'
    Write-Host ''
    Write-Host '    To get it: open the Microsoft Store, search for "App Installer", and install'
    Write-Host '    or update it. Or download it from:'
    Write-Host '      https://github.com/microsoft/winget-cli/releases'
    Write-Host '    Then close this terminal, open a new one, and run this script again.'
    Write-Host ''
    Show-ManualInstallList
    Write-Host ''
    throw 'winget is required by this script. See the options above.'
}

function Install-App {
    param(
        [string]$Name,
        [string]$Id
    )

    Write-Host "==> $Name  ($Id)"

    $wingetArgs = @(
        'install',
        '--exact',
        '--id', $Id,
        '--source', 'winget',
        '--silent',
        '--accept-source-agreements',
        '--accept-package-agreements'
    )

    if ($DryRun) {
        Write-Host "      DRY RUN: winget $($wingetArgs -join ' ')"
        return
    }

    & winget @wingetArgs
    $code = [uint32]([int64]$LASTEXITCODE -band 0xFFFFFFFFL)

    if ($code -eq 0) {
        Write-Host '      installed.'
    }
    elseif ($code -eq $WingetNoUpgrade -or $code -eq $WingetAlreadyInstalled) {
        Write-Host '      already installed and up to date - skipping.'
    }
    elseif ($code -eq $WingetRebootToFinish -or $code -eq $WingetRebootRequired -or $code -eq $WingetRebootInitiated) {
        Write-Host '      installed, but Windows needs a REBOOT to finish.'
        [void]$Warnings.Add("$Name needs a Windows reboot to finish installing.")
    }
    else {
        Write-Host ('      FAILED (winget exit 0x{0:X8}).' -f $code)
        [void]$Failures.Add(('{0} ({1}) - winget exit 0x{2:X8}' -f $Name, $Id, $code))
    }
}

function Update-SessionEnvironment {
    # Installers write PATH and JAVA_HOME-style variables to the registry. A terminal that was
    # already open does not see them, so pull the machine + user environment back into THIS
    # process and try to carry on without a restart.
    foreach ($scope in @('Machine', 'User')) {
        $vars = [Environment]::GetEnvironmentVariables($scope)
        foreach ($key in $vars.Keys) {
            if ($key -eq 'Path') { continue }
            [Environment]::SetEnvironmentVariable($key, $vars[$key], 'Process')
        }
    }

    $chunks = New-Object System.Collections.ArrayList
    foreach ($scope in @('Machine', 'User')) {
        $p = [Environment]::GetEnvironmentVariable('Path', $scope)
        if ($p) {
            foreach ($entry in $p.Split(';')) {
                if ($entry -and $entry.Trim() -ne '') { [void]$chunks.Add($entry.Trim()) }
            }
        }
    }
    $env:Path = (($chunks | Select-Object -Unique) -join ';')
}

function Invoke-Quietly {
    # Run a native command and return its output lines (stdout and stderr together).
    # `java -version` writes to stderr, and on Windows PowerShell 5.1 a redirected stderr line
    # becomes an error record that would stop the script under $ErrorActionPreference = 'Stop',
    # so relax it for the duration of the call.
    param([string]$Command, [string[]]$Arguments)
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $lines = & $Command @Arguments 2>&1 | ForEach-Object { "$_" }
    }
    finally {
        $ErrorActionPreference = $saved
    }
    return $lines
}

function Install-Extensions {
    Write-Host '==> VS Code extensions'

    if ($DryRun) {
        foreach ($ext in $Extensions) { Write-Host "      DRY RUN: code --install-extension $($ext.Id)" }
        return
    }

    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Host '      the `code` command is not on PATH in this terminal yet.'
        $script:RestartNeeded = $true
        return
    }

    foreach ($ext in $Extensions) {
        Write-Host "      $($ext.Name)  ($($ext.Id))"
        $null = Invoke-Quietly -Command 'code' -Arguments @('--install-extension', $ext.Id)
        if ($LASTEXITCODE -ne 0) {
            [void]$Failures.Add("VS Code extension $($ext.Id) (exit $LASTEXITCODE)")
        }
    }
}

function Show-Verification {
    Write-Host ''
    Write-Host '==> Verifying'

    $missing = New-Object System.Collections.ArrayList

    $checks = @(
        @{ Label = 'code';    Command = 'code';    Args = @('--version') },
        @{ Label = 'git';     Command = 'git';     Args = @('--version') },
        @{ Label = 'gh';      Command = 'gh';      Args = @('--version') },
        @{ Label = 'pwsh';    Command = 'pwsh';    Args = @('--version') },
        @{ Label = 'copilot'; Command = 'copilot'; Args = @('--version') }
    )

    foreach ($check in $checks) {
        if (-not (Get-Command $check.Command -ErrorAction SilentlyContinue)) {
            Write-Host ('      {0,-8}: NOT FOUND' -f $check.Label)
            [void]$missing.Add($check.Label)
            continue
        }
        $output = Invoke-Quietly -Command $check.Command -Arguments $check.Args | Select-Object -First 1
        Write-Host ('      {0,-8}: {1}' -f $check.Label, ("$output").Trim())
    }

    # .NET: the course needs a 10.x SDK, not just any dotnet on PATH.
    if (Get-Command dotnet -ErrorAction SilentlyContinue) {
        $sdks = @(Invoke-Quietly -Command 'dotnet' -Arguments @('--list-sdks') | Where-Object { $_ -match '^10\.' })
        if ($sdks.Count -gt 0) {
            Write-Host ('      {0,-8}: SDK {1}' -f 'dotnet', ($sdks[-1] -split ' ')[0])
        }
        else {
            Write-Host ('      {0,-8}: found, but no .NET 10 SDK' -f 'dotnet')
            [void]$missing.Add('.NET 10 SDK')
        }
    }
    else {
        Write-Host ('      {0,-8}: NOT FOUND' -f 'dotnet')
        [void]$missing.Add('.NET 10 SDK')
    }

    # Java: the samples need JDK 21 or later.
    if (Get-Command java -ErrorAction SilentlyContinue) {
        $first = Invoke-Quietly -Command 'java' -Arguments @('-version') | Select-Object -First 1
        $major = 0
        if ("$first" -match 'version "(\d+)') { $major = [int]$Matches[1] }
        if ($major -ge 21) {
            Write-Host ('      {0,-8}: {1}' -f 'java', ("$first").Trim())
        }
        else {
            Write-Host ('      {0,-8}: {1} (needs 21 or later)' -f 'java', ("$first").Trim())
            [void]$missing.Add('JDK 21')
        }
    }
    else {
        Write-Host ('      {0,-8}: NOT FOUND' -f 'java')
        [void]$missing.Add('JDK 21')
    }

    if (-not $SkipExtensions -and (Get-Command code -ErrorAction SilentlyContinue)) {
        $installed = @(Invoke-Quietly -Command 'code' -Arguments @('--list-extensions') | ForEach-Object { $_.ToLowerInvariant() })
        foreach ($ext in $Extensions) {
            if ($installed -contains $ext.Id.ToLowerInvariant()) {
                Write-Host ('      {0,-8}: {1}' -f 'ext', $ext.Id)
            }
            else {
                Write-Host ('      {0,-8}: {1} NOT INSTALLED' -f 'ext', $ext.Id)
                [void]$missing.Add($ext.Id)
            }
        }
    }

    return $missing
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

Write-Host '==> GitHub Copilot as a Coding-Agent Harness - Windows setup'
Write-Host "    $ScriptDir\setup.ps1"
Write-Host "    PowerShell $($PSVersionTable.PSVersion)"
if ($DryRun) { Write-Host '    DRY RUN - nothing will actually be installed.' }
Write-Host ''

if ($VerifyOnly) {
    $missing = @(Show-Verification)
    Write-Host ''
    if ($missing.Count -gt 0) {
        Write-Host "==> Missing: $($missing -join ', ')"
        Write-Host '    Run this script without -VerifyOnly to install them.'
        exit 1
    }
    Write-Host '==> Everything this course needs is installed.'
    Write-Host '    Next: sign in to GitHub in VS Code, and run `copilot` then /login once.'
    exit 0
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin  = (New-Object Security.Principal.WindowsPrincipal($identity)).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host '==> NOT running as administrator. Windows will prompt you (UAC) for some'
    Write-Host '    installers. That is fine; accept each prompt.'
    Write-Host ''
}

Assert-Winget
Write-Host ''

foreach ($app in $Apps) {
    Install-App -Name $app.Name -Id $app.Id
}
Write-Host ''

if (-not $DryRun) {
    Write-Host '==> Refreshing this terminal from the machine environment'
    Update-SessionEnvironment
    Write-Host ''
}

if ($SkipExtensions) {
    Write-Host '==> Skipping VS Code extensions (-SkipExtensions).'
    Write-Host ''
}
else {
    Install-Extensions
    Write-Host ''
}

$missing = @()
if (-not $DryRun) {
    $missing = @(Show-Verification)
    # If anything is still missing after a successful install, the most likely cause is a PATH
    # this terminal can't see yet - treat that as "reopen your terminal", not as a failure.
    if ($missing.Count -gt 0 -and $Failures.Count -eq 0) { $RestartNeeded = $true }
}

Write-Host ''
Write-Host '==> Summary'
Write-Host ('      failed   : {0}' -f $Failures.Count)
Write-Host ('      warnings : {0}' -f $Warnings.Count)

if ($Warnings.Count -gt 0) {
    Write-Host ''
    Write-Host '==> Warnings'
    foreach ($w in $Warnings) { Write-Host "      $w" }
}

if ($Failures.Count -gt 0) {
    Write-Host ''
    Write-Host '==> Failures'
    foreach ($f in $Failures) { Write-Host "      $f" }
    Write-Host ''
    Show-ManualInstallList
    Write-Host ''
    throw "$($Failures.Count) step(s) failed. See the list above."
}

if ($RestartNeeded) {
    Write-Host ''
    Write-Host '==> ACTION REQUIRED - open a NEW terminal'
    Write-Host ''
    Write-Host "    Still not visible in this terminal: $($missing -join ', ')"
    Write-Host '    New installs add themselves to PATH, and a terminal that was already open'
    Write-Host '    cannot always see the change.'
    Write-Host ''
    Write-Host '      1. Close this window.'
    Write-Host '      2. Open a NEW PowerShell window.'
    Write-Host '      3. Run this script again (it skips what is already installed):'
    Write-Host '           powershell -ExecutionPolicy Bypass -File .\setup.ps1'
    Write-Host ''
    Write-Host '    Nothing is broken - this is just how Windows environment variables work.'
    Write-Host ''
    exit 3
}

Write-Host ''
Write-Host '==> You are ready. Next:'
Write-Host '      1. Open VS Code and sign in to GitHub (the Copilot icon in the Status Bar).'
Write-Host '      2. Run `copilot`, then /login, to sign the Copilot CLI in.'
Write-Host '      3. Optional, to download every package ahead of class:'
Write-Host '           cd ..\utils'
Write-Host '           .\build-all.ps1'
