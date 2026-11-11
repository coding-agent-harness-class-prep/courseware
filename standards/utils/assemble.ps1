<#
.SYNOPSIS
    Build the repo's AGENTS.md from its two sources (Windows, PowerShell 7+).

.DESCRIPTION
    AGENTS.md = <course profile> + <shared standards>
              = AGENTS.course.md  + standards/AGENTS.base.md

    Edit those two SOURCE files, never the generated AGENTS.md. Run this after editing
    either. CLAUDE.md imports the generated AGENTS.md (`@AGENTS.md`); Copilot, Codex,
    Grok, Cursor, Gemini and other tools read AGENTS.md natively.

.EXAMPLE
    .\assemble.ps1
#>

$ErrorActionPreference = 'Stop'

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path        # standards/utils
$StandardsDir = (Resolve-Path (Join-Path $ScriptDir '..')).Path        # standards
$RepoRoot     = (Resolve-Path (Join-Path $StandardsDir '..')).Path     # repo root

$Base   = Join-Path $StandardsDir 'AGENTS.base.md'
$Course = Join-Path $RepoRoot     'AGENTS.course.md'
$Out    = Join-Path $RepoRoot     'AGENTS.md'

foreach ($f in @($Course, $Base)) {
    if (-not (Test-Path $f)) { throw "Missing source file: $f" }
}

$banner = @'
<!-- GENERATED FILE — do not edit. Assembled from AGENTS.course.md + standards/AGENTS.base.md
     by standards/utils/assemble.(sh|ps1). Edit those sources and re-run. -->
'@

$divider = '<!-- ===== Shared cross-course standards (standards/AGENTS.base.md) ===== -->'

$parts = @(
    $banner,
    '',
    (Get-Content -Raw $Course).TrimEnd(),
    '',
    '---',
    '',
    $divider,
    '',
    (Get-Content -Raw $Base).TrimEnd(),
    ''
)

# Write UTF-8 without BOM, LF line endings.
$text = ($parts -join "`n")
[System.IO.File]::WriteAllText($Out, $text, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Wrote $Out (from AGENTS.course.md + standards/AGENTS.base.md)"
