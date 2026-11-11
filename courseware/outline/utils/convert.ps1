<#
.SYNOPSIS
    Host wrapper for Windows (PowerShell 7+).

.DESCRIPTION
    Builds the outline-toolchain container image (if needed) and runs it against
    the outline directory, converting md\*.md into pdf\*.pdf.

.PARAMETER NoBuild
    Skip the image build and just run the conversion.

.EXAMPLE
    .\convert.ps1
    .\convert.ps1 -NoBuild
    $env:CONTAINER_ENGINE = 'docker'; .\convert.ps1

.NOTES
    Requires podman (default) or docker on PATH.
#>
param(
    [switch]$NoBuild
)

$ErrorActionPreference = 'Stop'

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutlineDir = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$Image      = 'copilot-harness-outline:latest'
$Engine     = if ($env:CONTAINER_ENGINE) { $env:CONTAINER_ENGINE } else { 'podman' }

if (-not (Get-Command $Engine -ErrorAction SilentlyContinue)) {
    throw "'$Engine' not found on PATH. Install podman (or set `$env:CONTAINER_ENGINE = 'docker')."
}

if (-not $NoBuild) {
    Write-Host "==> Building image '$Image' with $Engine"
    # -f is explicit because Docker, unlike podman, only looks for a file named Dockerfile.
    & $Engine build -t $Image -f (Join-Path $ScriptDir 'Containerfile') $ScriptDir
    if ($LASTEXITCODE -ne 0) { throw "Image build failed (exit $LASTEXITCODE)." }
}

Write-Host "==> Converting outline in: $OutlineDir"
# podman on Windows accepts the native path and maps it into the Linux VM.
& $Engine run --rm -v "${OutlineDir}:/work" -e OUTLINE_DIR=/work $Image
if ($LASTEXITCODE -ne 0) { throw "Conversion failed (exit $LASTEXITCODE)." }

Write-Host "==> Finished. Output is in:"
Write-Host "      $OutlineDir\pdf"
