#Requires -Version 5.1
<#
.SYNOPSIS
    Rolls back knowledge to a previous version
.DESCRIPTION
    Restores skills, agents, and memory from a backup.
    Supports rollback by:
    - Backup timestamp
    - Git tag
    - Relative reference (e.g., HEAD~1)
.PARAMETER Version
    Backup timestamp or git reference to rollback to
.PARAMETER WhatIf
    Show what would be restored without making changes
.EXAMPLE
    .\rollback.ps1 -Version "20260401-120000"
.EXAMPLE
    .\rollback.ps1 -Version "HEAD~1"
.EXAMPLE
    .\rollback.ps1 -Version "v1.0.0"
.EXAMPLE
    .\rollback.ps1 -Version "20260401-120000" -WhatIf
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [switch]$WhatIf
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\rollback.log"
$BackupRoot = "$ScriptDir\..\backups"
$ProjectRoot = "$PSScriptRoot\..\..\..\.."

Write-Log "Starting rollback to: $Version" $LogPath

try {
    Write-Host "`n=== Knowledge Rollback ===" -ForegroundColor Cyan
    Write-Host "Target version: $Version" -ForegroundColor Gray
    
    # Determine rollback source
    $backupDir = "$BackupRoot\$Version"
    $useGit = $false
    
    if (-not (Test-Path $backupDir)) {
        # Try git rollback
        if (Test-GitAvailable) {
            Write-Host "Backup not found, checking git..." -ForegroundColor Yellow
            $useGit = $true
        } else {
            Write-Host "Backup not found: $backupDir" -ForegroundColor Red
            exit 1
        }
    }
    
    if ($useGit) {
        # Git-based rollback
        Write-Host "`n[Git Rollback]" -ForegroundColor Green
        
        if ($WhatIf) {
            Write-Host "  [WhatIf] Would rollback git to: $Version" -ForegroundColor Yellow
            $diff = Get-GitDiff -From $Version -To "HEAD"
            Write-Host "  Files that would change:" -ForegroundColor Gray
            Write-Host $diff -ForegroundColor DarkGray
        } else {
            # Create pre-rollback backup
            Write-Host "  Creating pre-rollback backup..." -ForegroundColor Gray
            & "$ScriptDir\backup-knowledge.ps1"
            
            # Perform git rollback
            Write-Host "  Rolling back git..." -ForegroundColor Gray
            Rollback-Git -Target $Version
            
            Write-Host "  Git rollback complete" -ForegroundColor Green
        }
    } else {
        # Backup-based rollback
        Write-Host "`n[Backup Rollback]" -ForegroundColor Green
        
        # Read manifest
        $manifestFile = "$backupDir\manifest.json"
        if (-not (Test-Path $manifestFile)) {
            Write-Host "Manifest not found in backup" -ForegroundColor Red
            exit 1
        }
        
        $manifest = Get-Content $manifestFile -Raw | ConvertFrom-Json
        
        Write-Host "  Backup created: $($manifest.Created)" -ForegroundColor Gray
        Write-Host "  Backup type: $($manifest.Type)" -ForegroundColor Gray
        
        # Restore skills
        $skillsBackup = "$backupDir\skills"
        if (Test-Path $skillsBackup) {
            $skillsDir = "$PSScriptRoot\..\..\.."
            
            if ($WhatIf) {
                Write-Host "  [WhatIf] Would restore $($manifest.Stats.Skills) skills" -ForegroundColor Yellow
            } else {
                Write-Host "  Restoring skills..." -ForegroundColor Gray
                Get-ChildItem -Path $skillsBackup -Directory | ForEach-Object {
                    $skillFile = "$($_.FullName)\SKILL.md"
                    if (Test-Path $skillFile) {
                        $dest = "$skillsDir\$($_.Name)\SKILL.md"
                        Copy-Item -Path $skillFile -Destination $dest -Force
                    }
                }
                Write-Host "  Skills restored" -ForegroundColor Green
            }
        }
        
        # Restore agents
        $agentsBackup = "$backupDir\agents"
        if (Test-Path $agentsBackup) {
            $agentsDir = "$PSScriptRoot\..\..\agents"
            
            if ($WhatIf) {
                Write-Host "  [WhatIf] Would restore $($manifest.Stats.Agents) agents" -ForegroundColor Yellow
            } else {
                Write-Host "  Restoring agents..." -ForegroundColor Gray
                if (-not (Test-Path $agentsDir)) {
                    New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
                }
                Get-ChildItem -Path $agentsBackup -File | ForEach-Object {
                    Copy-Item -Path $_.FullName -Destination "$agentsDir\" -Force
                }
                Write-Host "  Agents restored" -ForegroundColor Green
            }
        }
        
        # Restore memory
        $memoryBackup = "$backupDir\memory"
        if (Test-Path $memoryBackup) {
            $memoryDir = "$PSScriptRoot\..\..\..\remember"
            
            if ($WhatIf) {
                Write-Host "  [WhatIf] Would restore $($manifest.Stats.Memory) memory files" -ForegroundColor Yellow
            } else {
                Write-Host "  Restoring memory..." -ForegroundColor Gray
                if (Test-Path $memoryDir) {
                    Remove-Item -Path $memoryDir -Recurse -Force
                }
                Copy-Item -Path $memoryBackup -Destination $memoryDir -Recurse -Force
                Write-Host "  Memory restored" -ForegroundColor Green
            }
        }
        
        # Restore config files
        $configBackup = "$backupDir\config"
        if (Test-Path $configBackup) {
            if ($WhatIf) {
                Write-Host "  [WhatIf] Would restore $($manifest.Stats.Config) config files" -ForegroundColor Yellow
            } else {
                Write-Host "  Restoring config files..." -ForegroundColor Gray
                Get-ChildItem -Path $configBackup -File | ForEach-Object {
                    Copy-Item -Path $_.FullName -Destination "$ProjectRoot\" -Force
                }
                Write-Host "  Config files restored" -ForegroundColor Green
            }
        }
    }
    
    Write-Host "`n=== Rollback Complete ===" -ForegroundColor Green
    
    if ($WhatIf) {
        Write-Host "`n[WhatIf] No changes were made" -ForegroundColor Yellow
    } else {
        Write-Host "Successfully rolled back to: $Version" -ForegroundColor Green
        Write-Log "Rollback complete to: $Version" $LogPath
    }
}
catch {
    Write-Log "Error during rollback: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
