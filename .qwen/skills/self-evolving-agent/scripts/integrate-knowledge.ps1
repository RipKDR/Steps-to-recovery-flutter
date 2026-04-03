#Requires -Version 5.1
<#
.SYNOPSIS
    Integrates new knowledge into skills, agents, and memory
.DESCRIPTION
    Merges pending learnings with existing knowledge bases,
    resolves conflicts, and updates all relevant files.
.PARAMETER Priority
    Filter by priority (low, medium, high, critical)
.PARAMETER DryRun
    Show what would be integrated without making changes
.EXAMPLE
    .\integrate-knowledge.ps1
.EXAMPLE
    .\integrate-knowledge.ps1 -Priority High
.EXAMPLE
    .\integrate-knowledge.ps1 -DryRun
#>

param(
    [ValidateSet('low', 'medium', 'high', 'critical')]
    [string]$Priority,
    [switch]$DryRun
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\integration.log"
$LearningsPath = "$ScriptDir\..\knowledge\pending-learnings.json"
$MemoryDir = "$PSScriptRoot\..\..\..\remember\logs\autonomous"
$KnowledgeDir = "$ScriptDir\..\knowledge"

Write-Log "Starting knowledge integration" $LogPath

try {
    # Get pending learnings
    $PendingLearnings = @()
    if (Test-Path $LearningsPath) {
        $PendingLearnings = Read-JsonFile -Path $LearningsPath -ReturnEmptyIfMissing
    }
    
    if ($PendingLearnings.Count -eq 0) {
        Write-Log "No pending learnings to integrate" $LogPath
        Write-Host "No pending learnings to integrate" -ForegroundColor Yellow
        exit 0
    }
    
    # Filter by priority if specified
    if ($Priority) {
        $PendingLearnings = $PendingLearnings | Where-Object { $_.Priority -eq $Priority }
        
        if ($PendingLearnings.Count -eq 0) {
            Write-Log "No learnings with priority: $Priority" $LogPath
            Write-Host "No learnings with priority: $Priority" -ForegroundColor Yellow
            exit 0
        }
    }
    
    Write-Log "Integrating $($PendingLearnings.Count) learning(s)" $LogPath
    
    $IntegratedCount = 0
    
    foreach ($learning in $PendingLearnings) {
        Write-Log "Processing learning: $($learning.Topic)" $LogPath
        
        # Categorize learning
        $category = $learning.Category
        $topic = $learning.Topic
        $insight = $learning.Insight
        
        # Integrate into appropriate knowledge base
        switch ($category) {
            'Correction' {
                Integrate-Correction -Learning $learning -MemoryDir $MemoryDir -DryRun:$DryRun
            }
            'Success' {
                Integrate-Success -Learning $learning -MemoryDir $MemoryDir -DryRun:$DryRun
            }
            'Error' {
                Integrate-Error -Learning $learning -MemoryDir $MemoryDir -DryRun:$DryRun
            }
            'Preference' {
                Integrate-Preference -Learning $learning -MemoryDir $MemoryDir -DryRun:$DryRun
            }
            default {
                Integrate-General -Learning $learning -KnowledgeDir $KnowledgeDir -DryRun:$DryRun
            }
        }
        
        # Mark as integrated
        $learning.Status = "Integrated"
        $learning.IntegratedAt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        $IntegratedCount++
    }
    
    # Remove integrated learnings from pending
    $RemainingLearnings = $PendingLearnings | Where-Object { $_.Status -ne "Integrated" }
    
    if (-not $DryRun) {
        Write-JsonFile -Path $LearningsPath -Data $RemainingLearnings -Backup:$true
        Write-Log "Removed $IntegratedCount integrated learnings from pending" $LogPath
    }
    
    # Sync with memory system
    if (-not $DryRun) {
        & "$ScriptDir\sync-memory.ps1"
    }
    
    # Commit changes
    if (-not $DryRun -and (Test-GitAvailable)) {
        $message = "chore(knowledge): integrated $IntegratedCount learning(s)"
        Add-FilesToGit @("$KnowledgeDir", "$MemoryDir")
        Commit-Git -Message $message
        Write-Log "Committed knowledge integration" $LogPath
    }
    
    # Summary
    Write-Host "`n=== Knowledge Integration Summary ===" -ForegroundColor Cyan
    Write-Host "Integrated $IntegratedCount learning(s)" -ForegroundColor Green
    
    if ($DryRun) {
        Write-Host "`n[DRY RUN] No changes were made" -ForegroundColor Yellow
    }
}
catch {
    Write-Log "Error during knowledge integration: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Log "Knowledge integration complete" $LogPath

function Integrate-Correction {
    param(
        [PSCustomObject]$Learning,
        [string]$MemoryDir,
        [switch]$DryRun
    )
    
    $correctionsFile = "$MemoryDir\corrections.md"
    $entry = @"

## $(Get-Date -Format "yyyy-MM-dd HH:mm") - $($Learning.Topic)

**Context:** $($Learning.Context)
**Correction:** $($Learning.Insight)
**Action:** $($Learning.Action)

"@
    
    if (-not $DryRun) {
        if (Test-Path $correctionsFile) {
            Add-Content -Path $correctionsFile -Value $entry -Encoding UTF8
        } else {
            "# Corrections Log`n`nThis file tracks corrections and learnings from errors.`n" | 
                Out-File -FilePath $correctionsFile -Encoding UTF8
            Add-Content -Path $correctionsFile -Value $entry -Encoding UTF8
        }
        
        Write-Host "  Integrated correction: $($Learning.Topic)" -ForegroundColor Gray
    } else {
        Write-Host "  [DRY RUN] Would integrate correction: $($Learning.Topic)" -ForegroundColor Yellow
    }
}

function Integrate-Success {
    param(
        [PSCustomObject]$Learning,
        [string]$MemoryDir,
        [switch]$DryRun
    )
    
    $memoryFile = "$MemoryDir\memory.md"
    $entry = "- **$($Learning.Topic)**: $($Learning.Insight) [$(Get-Date -Format "yyyy-MM-dd")]"
    
    if (-not $DryRun) {
        if (Test-Path $memoryFile) {
            $content = Get-Content $memoryFile -Raw -Encoding UTF8
            $content = "$content`r`n$entry"
            Set-Content -Path $memoryFile -Value $content -Encoding UTF8
        } else {
            "# Active Memory`n`n$entry`n" | Out-File -FilePath $memoryFile -Encoding UTF8
        }
        
        Write-Host "  Integrated success: $($Learning.Topic)" -ForegroundColor Gray
    } else {
        Write-Host "  [DRY RUN] Would integrate success: $($Learning.Topic)" -ForegroundColor Yellow
    }
}

function Integrate-Error {
    param(
        [PSCustomObject]$Learning,
        [string]$MemoryDir,
        [switch]$DryRun
    )
    
    $reflectionsFile = "$MemoryDir\reflections.md"
    $entry = @"

## Error Learning: $($Learning.Topic) - $(Get-Date -Format "yyyy-MM-dd HH:mm")

**Error Context:** $($Learning.Context)
**Root Cause:** $($Learning.Insight)
**Prevention:** $($Learning.Action)

"@
    
    if (-not $DryRun) {
        if (Test-Path $reflectionsFile) {
            Add-Content -Path $reflectionsFile -Value $entry -Encoding UTF8
        } else {
            "# Self-Reflections`n`n" | Out-File -FilePath $reflectionsFile -Encoding UTF8
            Add-Content -Path $reflectionsFile -Value $entry -Encoding UTF8
        }
        
        Write-Host "  Integrated error learning: $($Learning.Topic)" -ForegroundColor Gray
    } else {
        Write-Host "  [DRY RUN] Would integrate error: $($Learning.Topic)" -ForegroundColor Yellow
    }
}

function Integrate-Preference {
    param(
        [PSCustomObject]$Learning,
        [string]$MemoryDir,
        [switch]$DryRun
    )
    
    $userFile = "$PSScriptRoot\..\..\..\remember\USER.md"
    $entry = "- $($Learning.Insight)"
    
    if (-not $DryRun) {
        if (Test-Path $userFile) {
            $content = Get-Content $userFile -Raw -Encoding UTF8
            
            # Find preferences section or add new
            if ($content -match "## Preferences") {
                $content = $content -replace "(## Preferences\r?\n)", "`$1$entry`r`n"
            } else {
                $content = "$content`r`n`r`n## Preferences`r`n$entry`r`n"
            }
            
            Set-Content -Path $userFile -Value $content -Encoding UTF8
        }
        
        Write-Host "  Integrated preference: $($Learning.Topic)" -ForegroundColor Gray
    } else {
        Write-Host "  [DRY RUN] Would integrate preference: $($Learning.Topic)" -ForegroundColor Yellow
    }
}

function Integrate-General {
    param(
        [PSCustomObject]$Learning,
        [string]$KnowledgeDir,
        [switch]$DryRun
    )
    
    $generalFile = "$KnowledgeDir\general-learnings.json"
    
    if (-not $DryRun) {
        $existing = @()
        if (Test-Path $generalFile) {
            $existing = Read-JsonFile -Path $generalFile -ReturnEmptyIfMissing
        }
        
        $existing += $Learning
        Write-JsonFile -Path $generalFile -Data $existing -Backup:$true
        
        Write-Host "  Integrated general learning: $($Learning.Topic)" -ForegroundColor Gray
    } else {
        Write-Host "  [DRY RUN] Would integrate general: $($Learning.Topic)" -ForegroundColor Yellow
    }
}
