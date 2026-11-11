<#
.SYNOPSIS
    Restore and build every project under courseware/ (the four samples and the validation
    harness) - Windows, PowerShell 7+.

.DESCRIPTION
    Walks courseware/ and finds projects structurally, by the file that defines them:

      *.slnx                 .NET solution     restore: dotnet restore    build: dotnet build --no-restore
      pom.xml + mvnw(.cmd)   Maven project     restore: mvnw dependency:resolve    build: mvnw -DskipTests package
      package.json           npm project       restore: npm install       build: npm run build (if defined)

    Build output (bin, obj, target, node_modules, .git) is pruned from the walk, and the partial
    trees under demos/ and activities/ (assets/ and solution/ overlays) define no project, so
    they're never picked up on their own.

    This is the broad sweep that makes a fresh clone, or a fresh VM image, ready to go: it
    downloads every NuGet package, Maven artifact, and npm module the course needs, so nobody
    waits on a download in the middle of an activity. It deliberately doesn't prove the samples
    BEHAVE: that's courseware\validations (`npm test`), which runs every test suite and every
    solution and repro-test scenario.

    Continue-on-error by design: one broken project must not hide the state of the others.
    Failures are collected, listed at the end, and the script fails.

    Needs the tools for the projects it finds: the .NET SDK, a JDK (the Maven Wrapper fetches
    Maven itself), and Node.js. No container engine is needed.

.PARAMETER Path
    Only process projects whose courseware-relative folder matches this wildcard,
    e.g. -Path 'samples/*-java', -Path '*library*'.

.PARAMETER SkipInstall
    Don't restore; only build.

.PARAMETER SkipBuild
    Don't build; only restore.

.PARAMETER Force
    Run `npm install` even in npm projects that already have node_modules. (.NET and Maven
    restores are always run; they're quick when the caches are warm.)

.PARAMETER List
    Print the projects that would be processed, then exit.

.EXAMPLE
    .\build-all.ps1
    .\build-all.ps1 -Path 'samples/orders-*'
    .\build-all.ps1 -SkipBuild
    .\build-all.ps1 -List

.NOTES
    To remove the build output this creates, use the validations harness:
        cd ..\validations; npm run clean
#>
param(
    [string]$Path,
    [switch]$SkipInstall,
    [switch]$SkipBuild,
    [switch]$Force,
    [switch]$List
)

$ErrorActionPreference = 'Stop'

# PowerShell 7.4+ turns a non-zero native exit code into a terminating error when
# $ErrorActionPreference is 'Stop'. We inspect $LASTEXITCODE ourselves so the sweep
# can keep going past a failing project.
$PSNativeCommandUseErrorActionPreference = $false

$ScriptDir     = Split-Path -Parent $MyInvocation.MyCommand.Path        # courseware/utils
$CoursewareDir = (Resolve-Path (Join-Path $ScriptDir '..')).Path        # courseware

# Directory names we never descend into.
$Pruned = @('node_modules', '.git', 'bin', 'obj', 'target', 'TestResults', '.vs', '.idea')

function Get-Project {
    param([string]$Root)

    $found = New-Object System.Collections.Generic.List[object]
    $queue = New-Object System.Collections.Generic.Queue[string]
    $queue.Enqueue($Root)

    while ($queue.Count -gt 0) {
        $dir = $queue.Dequeue()
        $kind = $null
        if (@([System.IO.Directory]::GetFiles($dir, '*.slnx')).Count -gt 0) {
            $kind = 'dotnet'
        }
        elseif ((Test-Path -LiteralPath (Join-Path $dir 'pom.xml') -PathType Leaf) -and
                (Test-Path -LiteralPath (Join-Path $dir 'mvnw.cmd') -PathType Leaf)) {
            $kind = 'maven'
        }
        elseif (Test-Path -LiteralPath (Join-Path $dir 'package.json') -PathType Leaf) {
            $kind = 'npm'
        }

        if ($kind) {
            # A project's own folder is the whole project; don't look for nested ones.
            $found.Add([pscustomobject]@{ Folder = $dir; Kind = $kind })
            continue
        }
        foreach ($sub in [System.IO.Directory]::GetDirectories($dir)) {
            if ($Pruned -contains (Split-Path $sub -Leaf)) { continue }
            $queue.Enqueue($sub)
        }
    }
    return $found
}

function Get-RelativeName {
    param([string]$Full)
    return $Full.Substring($CoursewareDir.Length).TrimStart('\', '/').Replace('\', '/')
}

function Test-HasBuildScript {
    param([string]$Folder)
    try {
        $pkg = Get-Content -Raw -LiteralPath (Join-Path $Folder 'package.json') | ConvertFrom-Json
    } catch {
        return $false
    }
    if (-not $pkg.scripts) { return $false }
    $build = $pkg.scripts.PSObject.Properties['build']
    return ($null -ne $build -and -not [string]::IsNullOrWhiteSpace($build.Value))
}

# Run a native command, retrying once: restores fail transiently often enough to matter
# (a dropped connection on conference wifi, a momentary file lock from antivirus), and
# a genuinely broken project fails both attempts and is still reported.
function Invoke-WithRetry {
    param([scriptblock]$Command, [string]$Label)
    $exit = 0
    for ($attempt = 1; $attempt -le 2; $attempt++) {
        & $Command | Out-Host          # show the output; don't let it become our return value
        $exit = $LASTEXITCODE
        if ($exit -eq 0) { break }
        if ($attempt -lt 2) {
            Write-Host "         $Label : exit $exit -- retrying once (transient?)"
            Start-Sleep -Seconds 3
        }
    }
    return $exit
}

$projects = @(Get-Project -Root $CoursewareDir | Sort-Object Folder)

if ($Path) {
    $projects = @($projects | Where-Object { (Get-RelativeName $_.Folder) -like $Path })
}

if ($projects.Count -eq 0) {
    $where = if ($Path) { " matching '$Path'" } else { '' }
    throw "No projects found under $CoursewareDir$where."
}

if ($List) {
    Write-Host "==> $($projects.Count) project(s) under $CoursewareDir"
    foreach ($p in $projects) { Write-Host ('      {0,-7} {1}' -f $p.Kind, (Get-RelativeName $p.Folder)) }
    exit 0
}

# Check for the tools the discovered projects need, before doing any work.
$needed = @{ dotnet = 'dotnet'; maven = 'java'; npm = 'npm' }
foreach ($kind in @($projects.Kind | Sort-Object -Unique)) {
    $tool = $needed[$kind]
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "'$tool' was not found on PATH, and $kind projects need it. See ..\setup\README.md."
    }
}

$restored = 0
$skipped  = 0
$built    = 0
$noBuild  = 0
$failures = New-Object System.Collections.Generic.List[string]

$total   = $projects.Count
$index   = 0
$overall = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "==> Sweeping $total project(s) under $CoursewareDir"
if ($SkipInstall) { Write-Host "    (-SkipInstall: not restoring)" }
if ($SkipBuild)   { Write-Host "    (-SkipBuild: not building)" }
if ($Force)       { Write-Host "    (-Force: reinstalling npm projects even where node_modules exists)" }
Write-Host ""

foreach ($project in $projects) {
    $index++
    $folder = $project.Folder
    $name = Get-RelativeName $folder
    Write-Host ("[{0,2}/{1}] {2} ({3})" -f $index, $total, $name, $project.Kind)

    Push-Location -LiteralPath $folder
    try {
        $mvnw = Join-Path $folder 'mvnw.cmd'

        # ---- restore ---------------------------------------------------------
        if (-not $SkipInstall) {
            $skip = $project.Kind -eq 'npm' -and -not $Force -and
                    (Test-Path -LiteralPath (Join-Path $folder 'node_modules') -PathType Container)
            if ($skip) {
                Write-Host '         restore : skipped (node_modules already present; -Force to reinstall)'
                $skipped++
            }
            else {
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                switch ($project.Kind) {
                    'dotnet' {
                        Write-Host '         restore : dotnet restore ...'
                        $exit = Invoke-WithRetry -Label 'restore' { & dotnet restore --verbosity quiet }
                    }
                    'maven' {
                        Write-Host '         restore : mvnw dependency:resolve ...'
                        $exit = Invoke-WithRetry -Label 'restore' { & $mvnw -B -q dependency:resolve }
                    }
                    'npm' {
                        Write-Host '         restore : npm install ...'
                        $exit = Invoke-WithRetry -Label 'restore' { & npm install --no-audit --no-fund --loglevel=error }
                    }
                }
                $sw.Stop()
                if ($exit -ne 0) {
                    Write-Host "         restore : FAILED (exit $exit, after 2 attempts)"
                    $failures.Add("$name - restore (exit $exit, after 2 attempts)")
                    continue
                }
                Write-Host ('         restore : ok ({0:n1}s)' -f $sw.Elapsed.TotalSeconds)
                $restored++
            }
        }

        # ---- build -----------------------------------------------------------
        if (-not $SkipBuild) {
            if ($project.Kind -eq 'npm' -and -not (Test-HasBuildScript $folder)) {
                Write-Host '         build   : none (no "build" script in package.json)'
                $noBuild++
                continue
            }
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            switch ($project.Kind) {
                'dotnet' {
                    Write-Host '         build   : dotnet build ...'
                    & dotnet build --no-restore --verbosity quiet --nologo
                }
                'maven' {
                    Write-Host '         build   : mvnw -DskipTests package ...'
                    & $mvnw -B -q -DskipTests package
                }
                'npm' {
                    Write-Host '         build   : npm run build ...'
                    & npm run build
                }
            }
            $exit = $LASTEXITCODE
            $sw.Stop()
            if ($exit -ne 0) {
                Write-Host "         build   : FAILED (exit $exit)"
                $failures.Add("$name - build (exit $exit)")
                continue
            }
            Write-Host ('         build   : ok ({0:n1}s)' -f $sw.Elapsed.TotalSeconds)
            $built++
        }
    }
    finally {
        Pop-Location
    }
}

$overall.Stop()

Write-Host ''
Write-Host '==> Summary'
Write-Host ('      projects : {0}' -f $total)
Write-Host ('      restored : {0}  ({1} skipped - npm project already had node_modules)' -f $restored, $skipped)
Write-Host ('      built    : {0}  ({1} had nothing to build)' -f $built, $noBuild)
Write-Host ('      failed   : {0}' -f $failures.Count)
Write-Host ('      elapsed  : {0:n1}s' -f $overall.Elapsed.TotalSeconds)

if ($failures.Count -gt 0) {
    Write-Host ''
    Write-Host '==> Failures'
    foreach ($f in $failures) { Write-Host "      $f" }
    Write-Host ''
    throw "$($failures.Count) project(s) failed. See the list above."
}

Write-Host ''
Write-Host '==> All good. Next, prove the samples behave as the course says:'
Write-Host '      cd ..\validations; npm ci; npm test'
