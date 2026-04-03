#Requires -Version 5.1
<#
.SYNOPSIS
    Runs the complete improvement cycle
.DESCRIPTION
    Executes the full self-improvement loop:
    1. Analyze last response
    2. Identify knowledge gaps
    3. Fetch targeted documentation
    4. Integrate knowledge
    5. Update skills and agents
    6. Sync memory
    7. Promote important learnings
.PARAMETER Full
    Run full cycle including doc fetch (slower)
.PARAMETER Quick
    Run quick cycle (analysis and integration only)
.PARAMETER DryRun
    Show what would be done without making changes
.EXAMPLE
    .\run-improvement-cycle.ps1
.EXAMPLE
    .\run-improvement-cycle.ps1 -Full
.EXAMPLE
    .\run-improvement-cycle.ps1 -Quick
.EXAMPLE
    .\run-improvement-cycle.ps1 -DryRun
#>

param(
    [switch]$Full,
    [switch]$Quick,
    [switch]$DryRun
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\improvement-cycle.log"

Write-Log "Starting improvement cycle" $LogPath

try {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   Self-Improvement Cycle              ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    $startTime = Get-Date
    
    # Phase 1: Analyze Response
    Write-Host "[Phase 1/6] Analyzing response..." -ForegroundColor Green
    & "$ScriptDir\analyze-response.ps1" -OutputFormat File
    
    # Phase 2: Identify Knowledge Gaps
    Write-Host "`n[Phase 2/6] Identifying knowledge gaps..." -ForegroundColor Green
    & "$ScriptDir\identify-gaps.ps1"
    
    # Phase 3: Fetch Documentation (skip in quick mode)
    if (-not $Quick) {
        Write-Host "`n[Phase 3/6] Fetching documentation..." -ForegroundColor Green
        if ($Full) {
            & "$ScriptDir\fetch-docs.ps1" -All
        } else {
            & "$ScriptDir\fetch-docs.ps1" -Targeted
        }
    } else {
        Write-Host "  [Skipped in quick mode]" -ForegroundColor Yellow
    }
    
    # Phase 4: Integrate Knowledge
    Write-Host "`n[Phase 4/6] Integrating knowledge..." -ForegroundColor Green
    & "$ScriptDir\integrate-knowledge.ps1"
    
    # Phase 5: Update Skills and Agents
    Write-Host "`n[Phase 5/6] Updating skills and agents..." -ForegroundColor Green
    & "$ScriptDir\update-skills.ps1" -All
    & "$ScriptDir\update-agents.ps1" -All
    
    # Phase 6: Sync Memory and Promote
    Write-Host "`n[Phase 6/6] Syncing memory and promoting learnings..." -ForegroundColor Green
    & "$ScriptDir\sync-memory.ps1"
    & "$ScriptDir\promote-knowledge.ps1"
    
    # Calculate duration
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   Improvement Cycle Complete          ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "`nDuration: $([int]$duration.TotalSeconds)s" -ForegroundColor Gray
    
    Write-Log "Improvement cycle complete in $([int]$duration.TotalSeconds)s" $LogPath
}
catch {
    Write-Log "Error during improvement cycle: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
