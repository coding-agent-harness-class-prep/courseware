<#
.SYNOPSIS
    Host wrapper for Windows (PowerShell 7+).

.DESCRIPTION
    Builds the slide-toolchain container image (if needed) and runs it against
    the slides directory, converting md\*.md into pptx\ and pdf\ (plus a merged
    all-modules PDF).

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

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$SlidesDir   = (Resolve-Path (Join-Path $ScriptDir '..')).Path
# Diagrams live beside slides/, outside the /work mount, so they get their own
# read-only volume. preprocess.mjs reads from it to inline each figure.
$DiagramsDir = (Resolve-Path (Join-Path $SlidesDir '..\diagrams')).Path
$Image       = 'copilot-harness-slides:latest'
$Engine    = if ($env:CONTAINER_ENGINE) { $env:CONTAINER_ENGINE } else { 'podman' }

if (-not (Get-Command $Engine -ErrorAction SilentlyContinue)) {
    throw "'$Engine' not found on PATH. Install podman (or set `$env:CONTAINER_ENGINE = 'docker')."
}

if (-not $NoBuild) {
    Write-Host "==> Building image '$Image' with $Engine"
    # -f is explicit because Docker, unlike podman, only looks for a file named Dockerfile.
    & $Engine build -t $Image -f (Join-Path $ScriptDir 'Containerfile') $ScriptDir
    if ($LASTEXITCODE -ne 0) { throw "Image build failed (exit $LASTEXITCODE)." }
}

Write-Host "==> Converting slides in: $SlidesDir"
Write-Host "    diagrams from      : $DiagramsDir"
# podman on Windows accepts the native path and maps it into the Linux VM.
& $Engine run --rm `
    -v "${SlidesDir}:/work" `
    -v "${DiagramsDir}:/diagrams:ro" `
    -e SLIDES_DIR=/work -e DIAGRAMS_DIR=/diagrams $Image
if ($LASTEXITCODE -ne 0) { throw "Conversion failed (exit $LASTEXITCODE)." }

Write-Host "==> Finished. Outputs are in:"
Write-Host "      $SlidesDir\pptx"
Write-Host "      $SlidesDir\pdf"
