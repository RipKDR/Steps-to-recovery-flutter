param(
    [string]$Source = "docs/superpowers/skills/flutter-enhancement-mvp-planner",
    [string]$Destination = "$HOME/.codex/skills/flutter-enhancement-mvp-planner"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedSource = Join-Path $repoRoot $Source

if (-not (Test-Path $resolvedSource)) {
    throw "Skill source not found: $resolvedSource"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
Remove-Item -Recurse -Force $Destination -ErrorAction SilentlyContinue
Copy-Item -Recurse -Force $resolvedSource $Destination

Write-Host "Installed flutter-enhancement-mvp-planner to $Destination"
