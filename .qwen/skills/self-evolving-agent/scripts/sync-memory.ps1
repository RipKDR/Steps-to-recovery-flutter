#Requires -Version 5.1
<#
.SYNOPSIS
    Synchronizes knowledge with the .remember/ memory system
.DESCRIPTION
    Merges new learnings from skill logs into the appropriate
    memory tiers (HOT, corrections, reflections, domains, projects)
.PARAMETER Force
    Force sync even if no new learnings
.PARAMETER DryRun
    Show what would be synced without making changes
.EXAMPLE
    .\sync-memory.ps1
.EXAMPLE
    .\sync-memory.ps1 -Force
.EXAMPLE
    .\sync-memory.ps1 -DryRun
#>

param(
    [switch]$Force,
    [switch]$DryRun
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\memory-sync.log"
$KnowledgeDir = "$ScriptDir\..\knowledge"
$MemoryDir = "$PSScriptRoot\..\..\..\remember\logs\autonomous"
$ProjectMemoryDir = "$PSScriptRoot\..\..\..\remember\memory"

Write-Log "Starting memory synchronization" $LogPath

try {
    # Ensure memory directories exist
    $dirs = @(
        $MemoryDir,
        "$MemoryDir\domains",
        "$MemoryDir\projects",
        "$MemoryDir\archive",
        $ProjectMemoryDir
    )
    
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-Log "Created directory: $dir" $LogPath
            }
        }
    }
    
    # Initialize memory files if they don't exist
    Initialize-MemoryFiles -MemoryDir $MemoryDir -DryRun:$DryRun
    
    # Get general learnings
    $GeneralLearnings = @()
    if (Test-Path "$KnowledgeDir\general-learnings.json") {
        $GeneralLearnings = Read-JsonFile -Path "$KnowledgeDir\general-learnings.json" -ReturnEmptyIfMissing
    }
    
    if ($GeneralLearnings.Count -eq 0 -and -not $Force) {
        Write-Log "No new learnings to sync" $LogPath
        Write-Host "No new learnings to sync" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Log "Syncing $($GeneralLearnings.Count) learning(s)" $LogPath
    
    $SyncedCount = 0
    
    foreach ($learning in $GeneralLearnings) {
        if ($learning.Status -ne "Synced" -or $Force) {
            Sync-Learning -Learning $learning -MemoryDir $MemoryDir -DryRun:$DryRun
            $learning.Status = "Synced"
            $SyncedCount++
        }
    }
    
    # Update general learnings file
    if (-not $DryRun) {
        Write-JsonFile -Path "$KnowledgeDir\general-learnings.json" -Data $GeneralLearnings -Backup:$true
    }
    
    # Update project state
    if (-not $DryRun) {
        Update-ProjectState -ProjectMemoryDir $ProjectMemoryDir -Count $SyncedCount
    }
    
    # Summary
    Write-Host "`n=== Memory Sync Summary ===" -ForegroundColor Cyan
    Write-Host "Synced $SyncedCount learning(s) to memory system" -ForegroundColor Green
    
    if ($DryRun) {
        Write-Host "`n[DRY RUN] No changes were made" -ForegroundColor Yellow
    }
}
catch {
    Write-Log "Error during memory sync: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Log "Memory sync complete" $LogPath

function Initialize-MemoryFiles {
    param(
        [string]$MemoryDir,
        [switch]$DryRun
    )
    
    $files = @{
        "memory.md" = "# Active Memory (HOT)`n`nThis file contains currently active patterns and learnings.`n`n"
        "corrections.md" = "# Corrections Log`n`nThis file tracks corrections from user feedback and errors.`n`n"
        "reflections.md" = "# Self-Reflections`n`nAgent self-reflections and meta-learnings.`n`n"
        "index.md" = "# Memory Index`n`n"
    }
    
    foreach ($file in $files.Keys) {
        $filePath = "$MemoryDir\$file"
        if (-not (Test-Path $filePath)) {
            if (-not $DryRun) {
                $files[$file] | Out-File -FilePath $filePath -Encoding UTF8
                Write-Log "Initialized: $filePath" $LogPath
            } else {
                Write-Host "  [DRY RUN] Would initialize: $file" -ForegroundColor Yellow
            }
        }
    }
    
    # Initialize domain files
    $domains = @{
        "flutter.md" = "# Flutter Domain Knowledge`n`n"
        "dart.md" = "# Dart Domain Knowledge`n`n"
        "testing.md" = "# Testing Domain Knowledge`n`n"
    }
    
    foreach ($domain in $domains.Keys) {
        $filePath = "$MemoryDir\domains\$domain"
        if (-not (Test-Path $filePath)) {
            if (-not $DryRun) {
                $domains[$domain] | Out-File -FilePath $filePath -Encoding UTF8
                Write-Log "Initialized domain: $filePath" $LogPath
            } else {
                Write-Host "  [DRY RUN] Would initialize domain: $domain" -ForegroundColor Yellow
            }
        }
    }
    
    # Initialize project file
    $projectFile = "$MemoryDir\projects\steps-to-recovery.md"
    if (-not (Test-Path $projectFile)) {
        if (-not $DryRun) {
            "# Steps to Recovery Project Knowledge`n`nProject-specific patterns and learnings.`n" | 
                Out-File -FilePath $projectFile -Encoding UTF8
            Write-Log "Initialized project: $projectFile" $LogPath
        } else {
            Write-Host "  [DRY RUN] Would initialize project file" -ForegroundColor Yellow
        }
    }
}

function Sync-Learning {
    param(
        [PSCustomObject]$Learning,
        [string]$MemoryDir,
        [switch]$DryRun
    )
    
    $category = $Learning.Category
    $topic = $Learning.Topic
    $insight = $Learning.Insight
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    
    # Determine target file based on category and topic
    $targetFile = Get-TargetFile -Learning $Learning -MemoryDir $MemoryDir
    $entry = "- **[$timestamp]** $topic`: $insight"
    
    if (-not $DryRun) {
        if (Test-Path $targetFile) {
            $content = Get-Content $targetFile -Raw -Encoding UTF8
            $content = "$content`r`n$entry"
            Set-Content -Path $targetFile -Value $content -Encoding UTF8
        } else {
            "# Auto-Generated`n`n$entry`n" | Out-File -FilePath $targetFile -Encoding UTF8
        }
        
        Write-Host "  Synced to: $targetFile" -ForegroundColor Gray
    } else {
        Write-Host "  [DRY RUN] Would sync to: $targetFile" -ForegroundColor Yellow
    }
}

function Get-TargetFile {
    param(
        [PSCustomObject]$Learning,
        [string]$MemoryDir
    )
    
    $topic = $Learning.Topic.ToLower()
    $category = $Learning.Category
    
    # Route based on topic keywords
    if ($topic -match "flutter|widget|state|navigation|ui") {
        return "$MemoryDir\domains\flutter.md"
    }
    elseif ($topic -match "dart|null-safety|async|generics") {
        return "$MemoryDir\domains\dart.md"
    }
    elseif ($topic -match "test|mock|coverage") {
        return "$MemoryDir\domains\testing.md"
    }
    elseif ($topic -match "project|steps|recovery|app") {
        return "$MemoryDir\projects\steps-to-recovery.md"
    }
    elseif ($category -eq "Correction") {
        return "$MemoryDir\corrections.md"
    }
    elseif ($category -eq "Error") {
        return "$MemoryDir\reflections.md"
    }
    else {
        return "$MemoryDir\memory.md"
    }
}

function Update-ProjectState {
    param(
        [string]$ProjectMemoryDir,
        [int]$Count
    )
    
    $projectStateFile = "$ProjectMemoryDir\project-state.md"
    
    if (Test-Path $projectStateFile) {
        $content = Get-Content $projectStateFile -Raw -Encoding UTF8
        
        # Update last sync timestamp
        $content = $content -replace 
            '\*\*Last Knowledge Sync:\*\* .*',
            "**Last Knowledge Sync:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        
        # Add to learnings count if tracked
        if ($content -match "\*\*Total Learnings:\*\* (\d+)") {
            $newCount = [int]$matches[1] + $Count
            $content = $content -replace 
                "\*\*Total Learnings:\*\* \d+",
                "**Total Learnings:** $newCount"
        }
        
        Set-Content -Path $projectStateFile -Value $content -Encoding UTF8
    }
}
