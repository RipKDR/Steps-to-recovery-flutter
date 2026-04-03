#Requires -Version 5.1
<#
.SYNOPSIS
    Validates the self-evolving-agent installation
.DESCRIPTION
    Checks that all required files, scripts, and configurations are present and valid.
.EXAMPLE
    .\validate-self-skill.ps1
#>

param(
    [switch]$Full
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\validation.log"
$ProjectRoot = "$PSScriptRoot\..\..\..\.."

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Self-Evolving Agent Validation      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan

$Results = @{
    Passed = 0
    Failed = 0
    Warnings = 0
}

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$FixHint
    )
    
    Write-Host "  Checking: $Name" -ForegroundColor Gray
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host "    ✓ Pass" -ForegroundColor Green
            $Results.Passed++
        } else {
            Write-Host "    ✗ Fail" -ForegroundColor Red
            if ($FixHint) {
                Write-Host "    Hint: $FixHint" -ForegroundColor Yellow
            }
            $Results.Failed++
        }
    }
    catch {
        Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        $Results.Failed++
    }
}

Write-Host "`n[1/6] Directory Structure" -ForegroundColor Green

Test-Check "Scripts directory exists" {
    Test-Path "$ScriptDir"
} "Check script directory"

Test-Check "References directory exists" {
    Test-Path "$ScriptDir\..\references"
} "Check references directory"

Test-Check "Logs directory exists" {
    Test-Path "$ScriptDir\..\logs"
} "Check logs directory"

Test-Check "Knowledge directory exists" {
    Test-Path "$ScriptDir\..\knowledge"
} "Check knowledge directory"

Test-Check "Doc-cache directory exists" {
    Test-Path "$ScriptDir\..\doc-cache"
} "Check doc-cache directory"

Write-Host "`n[2/6] Core Scripts" -ForegroundColor Green

Test-Check "analyze-response.ps1 exists" {
    Test-Path "$ScriptDir\analyze-response.ps1"
} "Recreate the script"

Test-Check "update-skills.ps1 exists" {
    Test-Path "$ScriptDir\update-skills.ps1"
} "Recreate the script"

Test-Check "update-agents.ps1 exists" {
    Test-Path "$ScriptDir\update-agents.ps1"
} "Recreate the script"

Test-Check "fetch-docs.ps1 exists" {
    Test-Path "$ScriptDir\fetch-docs.ps1"
} "Recreate the script"

Test-Check "integrate-knowledge.ps1 exists" {
    Test-Path "$ScriptDir\integrate-knowledge.ps1"
} "Recreate the script"

Test-Check "sync-memory.ps1 exists" {
    Test-Path "$ScriptDir\sync-memory.ps1"
} "Recreate the script"

Test-Check "run-improvement-cycle.ps1 exists" {
    Test-Path "$ScriptDir\run-improvement-cycle.ps1"
} "Recreate the script"

Write-Host "`n[3/6] Utility Scripts" -ForegroundColor Green

Test-Check "logger.ps1 exists" {
    Test-Path "$ScriptDir\utils\logger.ps1"
} "Recreate the utility"

Test-Check "json-helpers.ps1 exists" {
    Test-Path "$ScriptDir\utils\json-helpers.ps1"
} "Recreate the utility"

Test-Check "git-helpers.ps1 exists" {
    Test-Path "$ScriptDir\utils\git-helpers.ps1"
} "Recreate the utility"

Write-Host "`n[4/6] Reference Documentation" -ForegroundColor Green

Test-Check "SKILL.md exists" {
    Test-Path "$ScriptDir\..\SKILL.md"
} "Recreate SKILL.md"

Test-Check "learning-patterns.md exists" {
    Test-Path "$ScriptDir\..\references\learning-patterns.md"
} "Recreate the reference"

Test-Check "knowledge-schema.md exists" {
    Test-Path "$ScriptDir\..\references\knowledge-schema.md"
} "Recreate the reference"

Test-Check "integration-rules.md exists" {
    Test-Path "$ScriptDir\..\references\integration-rules.md"
} "Recreate the reference"

Test-Check "doc-sources.md exists" {
    Test-Path "$ScriptDir\..\references\doc-sources.md"
} "Recreate the reference"

Test-Check "versioning-strategy.md exists" {
    Test-Path "$ScriptDir\..\references\versioning-strategy.md"
} "Recreate the reference"

Write-Host "`n[5/6] Configuration" -ForegroundColor Green

Test-Check "config.json exists" {
    Test-Path "$ScriptDir\..\config.json"
} "Create config.json"

Test-Check "config.json is valid JSON" {
    if (Test-Path "$ScriptDir\..\config.json") {
        $null = Get-Content "$ScriptDir\..\config.json" -Raw | ConvertFrom-Json
        return $true
    }
    return $false
} "Fix JSON syntax"

Write-Host "`n[6/6] Integration" -ForegroundColor Green

Test-Check "Memory directory accessible" {
    Test-Path "$ProjectRoot\.remember"
} "Check .remember directory exists"

Test-Check "Agents directory accessible" {
    # Use absolute path construction
    $qwenDir = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptDir))
    Test-Path "$qwenDir\agents"
} "Check .qwen/agents directory exists"

Test-Check "Skills directory accessible" {
    Test-Path "$PSScriptRoot\..\.."
} "Check .qwen/skills directory exists"

if ($Full) {
    Write-Host "`n[7/6] Full Validation (Extended)" -ForegroundColor Green
    
    Test-Check "Git available" {
        try {
            $null = git --version 2>&1
            return $true
        }
        catch {
            return $false
        }
    } "Install Git"
    
    Test-Check "PowerShell version >= 5.1" {
        $PSVersionTable.PSVersion -ge [Version]"5.1"
    } "Upgrade PowerShell"
}

# Summary
Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Validation Summary                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nResults:" -ForegroundColor White
Write-Host "  Passed:   $($Results.Passed)" -ForegroundColor Green
Write-Host "  Failed:   $($Results.Failed)" -ForegroundColor Red
Write-Host "  Warnings: $($Results.Warnings)" -ForegroundColor Yellow

if ($Results.Failed -eq 0) {
    Write-Host "`n✓ All checks passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n✗ Some checks failed. Please fix the issues above." -ForegroundColor Red
    exit 1
}
