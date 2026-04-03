#Requires -Version 5.1
<#
.SYNOPSIS
    Shows the changelog for a file
.DESCRIPTION
    Displays the git history and changes for a specific file.
.PARAMETER File
    File to show changelog for
.PARAMETER MaxCount
    Maximum number of commits to show (default: 20)
.EXAMPLE
    .\show-changelog.ps1 -File "SKILL.md"
.EXAMPLE
    .\show-changelog.ps1 -File "agents\flutter-widget-builder.md" -MaxCount 10
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$File,
    [int]$MaxCount = 20
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$ProjectRoot = "$PSScriptRoot\..\..\..\.."

try {
    Write-Host "`n=== Changelog for: $File ===" -ForegroundColor Cyan
    
    if (-not (Test-GitAvailable)) {
        Write-Host "Git not available" -ForegroundColor Red
        exit 1
    }
    
    # Get git log
    $log = Get-GitLog -Path $File -MaxCount $MaxCount
    
    if ($log) {
        Write-Host "`nRecent Changes:" -ForegroundColor Green
        Write-Host $log -ForegroundColor Gray
    } else {
        Write-Host "No git history found for this file" -ForegroundColor Yellow
    }
    
    # Show diff from last commit
    $lastDiff = Get-GitDiff -From "HEAD~1" -To "HEAD" -Path $File
    
    if ($lastDiff) {
        Write-Host "`nLast Change:" -ForegroundColor Green
        Write-Host $lastDiff -ForegroundColor DarkGray
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
