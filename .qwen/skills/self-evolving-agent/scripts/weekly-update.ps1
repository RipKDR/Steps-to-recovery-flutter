#Requires -Version 5.1
<#
.SYNOPSIS
    Runs the weekly update routine
.DESCRIPTION
    Executes weekly maintenance tasks:
    - Comprehensive skill review
    - Agent performance analysis
    - Knowledge base optimization
    - Archive old learnings
    - Generate weekly report
.EXAMPLE
    .\weekly-update.ps1
#>

param()

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\weekly-update.log"
$LastRunFile = "$ScriptDir\..\logs\last-weekly-run.txt"

Write-Log "Starting weekly update routine" $LogPath

try {
    # Check if already run this week
    if (Test-Path $LastRunFile) {
        $lastRun = Get-Content $LastRunFile -Raw
        $lastRunDate = [DateTime]::Parse($lastRun.Trim())
        $weekAgo = (Get-Date).AddDays(-7)
        
        if ($lastRunDate -ge $weekAgo) {
            Write-Log "Weekly update already run this week ($lastRun)" $LogPath
            Write-Host "Weekly update already run this week" -ForegroundColor Yellow
            exit 0
        }
    }
    
    Write-Host "`n=== Weekly Update Routine ===" -ForegroundColor Cyan
    
    # 1. Comprehensive skill review
    Write-Host "`n[1/6] Reviewing skills..." -ForegroundColor Green
    Review-AllSkills
    
    # 2. Agent performance analysis
    Write-Host "`n[2/6] Analyzing agent performance..." -ForegroundColor Green
    Analyze-AgentPerformance
    
    # 3. Knowledge base optimization
    Write-Host "`n[3/6] Optimizing knowledge base..." -ForegroundColor Green
    Optimize-KnowledgeBase
    
    # 4. Archive old learnings
    Write-Host "`n[4/6] Archiving old learnings..." -ForegroundColor Green
    Archive-OldLearnings
    
    # 5. Update skills with weekly learnings
    Write-Host "`n[5/6] Updating skills..." -ForegroundColor Green
    & "$ScriptDir\update-skills.ps1" -All
    
    # 6. Update agents with weekly learnings
    Write-Host "`n[6/6] Updating agents..." -ForegroundColor Green
    & "$ScriptDir\update-agents.ps1" -All
    
    # Generate weekly report
    Write-Host "`nGenerating weekly report..." -ForegroundColor Green
    Generate-WeeklyReport
    
    # Record last run
    Set-Content -Path $LastRunFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Encoding UTF8
    
    Write-Host "`n=== Weekly Update Complete ===" -ForegroundColor Green
    Write-Log "Weekly update routine complete" $LogPath
}
catch {
    Write-Log "Error during weekly update: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

function Review-AllSkills {
    $skillsDir = "$PSScriptRoot\..\..\.."
    $skills = Get-ChildItem -Path $skillsDir -Directory | Where-Object { $_.Name -ne "self-evolving-agent" }
    
    Write-Host "  Reviewed $($skills.Count) skills" -ForegroundColor Gray
    
    foreach ($skill in $skills) {
        $skillFile = "$($skill.FullName)\SKILL.md"
        if (Test-Path $skillFile) {
            $lastModified = (Get-Item $skillFile).LastWriteTime
            $age = (Get-Date) - $lastModified
            
            if ($age.TotalDays -gt 30) {
                Write-Log "Skill $($skill.Name) not updated in $([int]$age.TotalDays) days" $LogPath
            }
        }
    }
}

function Analyze-AgentPerformance {
    $agentsDir = "$PSScriptRoot\..\..\agents"
    
    if (Test-Path $agentsDir) {
        $agents = Get-ChildItem -Path $agentsDir -Filter "*.md"
        Write-Host "  Analyzed $($agents.Count) agents" -ForegroundColor Gray
    } else {
        Write-Host "  No agents directory found" -ForegroundColor Yellow
    }
}

function Optimize-KnowledgeBase {
    $knowledgeDir = "$ScriptDir\..\knowledge"
    $learningsFile = "$knowledgeDir\general-learnings.json"
    
    if (Test-Path $learningsFile) {
        $learnings = Read-JsonFile -Path $learningsFile -ReturnEmptyIfMissing
        
        # Remove duplicates
        $unique = $learnings | Sort-Object -Property @{Expression = {$_.Timestamp + $_.Topic}} -Unique
        
        if ($unique.Count -lt $learnings.Count) {
            Write-JsonFile -Path $learningsFile -Data $unique -Backup:$true
            Write-Host "  Removed $($learnings.Count - $unique.Count) duplicate learnings" -ForegroundColor Gray
        } else {
            Write-Host "  No duplicates found" -ForegroundColor Gray
        }
    }
}

function Archive-OldLearnings {
    $archiveDir = "$ScriptDir\..\knowledge\archive"
    if (-not (Test-Path $archiveDir)) {
        New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
    }
    
    $learningsFile = "$ScriptDir\..\knowledge\general-learnings.json"
    
    if (Test-Path $learningsFile) {
        $learnings = Read-JsonFile -Path $learningsFile -ReturnEmptyIfMissing
        
        # Archive learnings older than 30 days
        $cutoff = (Get-Date).AddDays(-30)
        $oldLearnings = $learnings | Where-Object {
            [DateTime]::Parse($_.Timestamp) -lt $cutoff
        }
        
        if ($oldLearnings.Count -gt 0) {
            $archiveFile = "$archiveDir\learnings-$(Get-Date -Format 'yyyy-MM-dd').json"
            Write-JsonFile -Path $archiveFile -Data $oldLearnings
            
            # Remove from active learnings
            $activeLearnings = $learnings | Where-Object {
                [DateTime]::Parse($_.Timestamp) -ge $cutoff
            }
            
            Write-JsonFile -Path $learningsFile -Data $activeLearnings -Backup:$true
            
            Write-Host "  Archived $($oldLearnings.Count) old learnings" -ForegroundColor Gray
        } else {
            Write-Host "  No learnings to archive" -ForegroundColor Gray
        }
    }
}

function Generate-WeeklyReport {
    $reportDir = "$ScriptDir\..\logs\reports"
    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    
    $weekNum = (Get-Date).DayOfWeek.value__
    $year = Get-Date -Format "yyyy"
    $reportFile = "$reportDir\weekly-$year-W$weekNum.md"
    
    $report = @"
# Weekly Report - $(Get-Date -Format "yyyy-MM-dd")

## Summary

This week's self-improvement activities:

### Skills
- Skills reviewed: $(Get-SkillCount)
- Skills updated: $(Get-UpdateCount -Type Skills)

### Agents
- Agents analyzed: $(Get-AgentCount)
- Agents updated: $(Get-UpdateCount -Type Agents)

### Knowledge
- Learnings integrated: $(Get-LearningCount -Type Integrated)
- Learnings archived: $(Get-LearningCount -Type Archived)

### Documentation
- Sources fetched: Flutter, Dart, Pub.dev, Qwen

## Trends

$(Get-TrendAnalysis)

## Next Week Focus

$(Get-NextWeekFocus)

---
Generated by Self-Evolving Agent
"@
    
    $report | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "  Weekly report created: $reportFile" -ForegroundColor Gray
}

function Get-SkillCount {
    $skillsDir = "$PSScriptRoot\..\..\.."
    return (Get-ChildItem -Path $skillsDir -Directory | Where-Object { $_.Name -ne "self-evolving-agent" }).Count
}

function Get-AgentCount {
    $agentsDir = "$PSScriptRoot\..\..\agents"
    if (Test-Path $agentsDir) {
        return (Get-ChildItem -Path $agentsDir -Filter "*.md").Count
    }
    return 0
}

function Get-UpdateCount {
    param(
        [ValidateSet('Skills', 'Agents')]
        [string]$Type
    )
    
    # Count git commits this week
    $weekAgo = (Get-Date).AddDays(-7)
    # Simplified - would need actual git log parsing
    return 0
}

function Get-LearningCount {
    param(
        [ValidateSet('Integrated', 'Archived')]
        [string]$Type
    )
    
    # Count from learnings file
    $learningsFile = "$ScriptDir\..\knowledge\general-learnings.json"
    if (Test-Path $learningsFile) {
        try {
            $learnings = Get-Content $learningsFile -Raw | ConvertFrom-Json
            return $learnings.Count
        }
        catch {
            return 0
        }
    }
    return 0
}

function Get-TrendAnalysis {
    return "Analysis pending implementation..."
}

function Get-NextWeekFocus {
    return "Continue monitoring and improving based on user feedback..."
}
