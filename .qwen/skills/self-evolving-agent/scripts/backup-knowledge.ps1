#Requires -Version 5.1
<#
.SYNOPSIS
    Creates backups of all knowledge files
.DESCRIPTION
    Backs up:
    - Skill files
    - Agent files
    - Memory files
    - Configuration files
    Stores in timestamped backup directory.
.PARAMETER Full
    Create full backup including docs cache
.PARAMETER Incremental
    Only backup changed files (default)
.EXAMPLE
    .\backup-knowledge.ps1
.EXAMPLE
    .\backup-knowledge.ps1 -Full
#>

param(
    [switch]$Full,
    [switch]$Incremental
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\backup.log"
$ProjectRoot = "$PSScriptRoot\..\..\..\.."
$BackupRoot = "$ScriptDir\..\backups"

Write-Log "Starting knowledge backup" $LogPath

try {
    # Create timestamped backup directory
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = "$BackupRoot\$timestamp"
    
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    Write-Host "`n=== Knowledge Backup ===" -ForegroundColor Cyan
    Write-Host "Backup directory: $backupDir" -ForegroundColor Gray
    
    $BackupStats = @{
        Skills = 0
        Agents = 0
        Memory = 0
        Config = 0
        TotalSize = 0
    }
    
    # Backup skills
    Write-Host "`n[1/4] Backing up skills..." -ForegroundColor Green
    $skillsBackup = "$backupDir\skills"
    if (-not (Test-Path $skillsBackup)) {
        New-Item -ItemType Directory -Path $skillsBackup -Force | Out-Null
    }
    
    $skillsDir = "$PSScriptRoot\..\..\.."
    Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
        $skillFile = "$($_.FullName)\SKILL.md"
        if (Test-Path $skillFile) {
            $dest = "$skillsBackup\$($_.Name)"
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
            Copy-Item -Path $skillFile -Destination "$dest\" -Force
            $BackupStats.Skills++
        }
    }
    Write-Host "  Backed up $($BackupStats.Skills) skills" -ForegroundColor Gray
    
    # Backup agents
    Write-Host "`n[2/4] Backing up agents..." -ForegroundColor Green
    $agentsBackup = "$backupDir\agents"
    if (-not (Test-Path $agentsBackup)) {
        New-Item -ItemType Directory -Path $agentsBackup -Force | Out-Null
    }
    
    $agentsDir = "$PSScriptRoot\..\..\agents"
    if (Test-Path $agentsDir) {
        Get-ChildItem -Path $agentsDir -Filter "*.md" | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination "$agentsBackup\" -Force
            $BackupStats.Agents++
        }
    }
    Write-Host "  Backed up $($BackupStats.Agents) agents" -ForegroundColor Gray
    
    # Backup memory
    Write-Host "`n[3/4] Backing up memory..." -ForegroundColor Green
    $memoryBackup = "$backupDir\memory"
    if (-not (Test-Path $memoryBackup)) {
        New-Item -ItemType Directory -Path $memoryBackup -Force | Out-Null
    }
    
    $memoryDir = "$PSScriptRoot\..\..\..\remember"
    if (Test-Path $memoryDir) {
        Copy-Item -Path $memoryDir -Destination $memoryBackup -Recurse -Force
        $BackupStats.Memory = (Get-ChildItem -Path $memoryBackup -Recurse -File).Count
    }
    Write-Host "  Backed up $($BackupStats.Memory) memory files" -ForegroundColor Gray
    
    # Backup config files
    Write-Host "`n[4/4] Backing up config files..." -ForegroundColor Green
    $configBackup = "$backupDir\config"
    if (-not (Test-Path $configBackup)) {
        New-Item -ItemType Directory -Path $configBackup -Force | Out-Null
    }
    
    $configFiles = @("AGENTS.md", "QWEN.md", "CLAUDE.md")
    foreach ($file in $configFiles) {
        if (Test-Path "$ProjectRoot\$file") {
            Copy-Item -Path "$ProjectRoot\$file" -Destination "$configBackup\" -Force
            $BackupStats.Config++
        }
    }
    Write-Host "  Backed up $($BackupStats.Config) config files" -ForegroundColor Gray
    
    # Calculate total size
    $backupSize = (Get-ChildItem -Path $backupDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $BackupStats.TotalSize = [math]::Round($backupSize / 1KB, 2)
    
    # Create backup manifest
    $manifest = @{
        Timestamp = $timestamp
        Created = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Type = if ($Full) { "Full" } else { "Incremental" }
        Stats = $BackupStats
        Files = (Get-ChildItem -Path $backupDir -Recurse -File | Select-Object -ExpandProperty FullName)
    }
    
    $manifest | ConvertTo-Json -Depth 5 | Out-File -FilePath "$backupDir\manifest.json" -Encoding UTF8
    
    # Clean old backups (keep last 10)
    $backups = Get-ChildItem -Path $BackupRoot -Directory | Sort-Object -Property Name -Descending
    if ($backups.Count -gt 10) {
        $backups[10..($backups.Count - 1)] | Remove-Item -Recurse -Force
        Write-Host "  Cleaned old backups" -ForegroundColor Gray
    }
    
    # Summary
    Write-Host "`n=== Backup Summary ===" -ForegroundColor Cyan
    Write-Host "Location: $backupDir" -ForegroundColor Gray
    Write-Host "Total Size: $($BackupStats.TotalSize) KB" -ForegroundColor Gray
    Write-Host "Files Backed Up:" -ForegroundColor Gray
    Write-Host "  - Skills: $($BackupStats.Skills)" -ForegroundColor Gray
    Write-Host "  - Agents: $($BackupStats.Agents)" -ForegroundColor Gray
    Write-Host "  - Memory: $($BackupStats.Memory)" -ForegroundColor Gray
    Write-Host "  - Config: $($BackupStats.Config)" -ForegroundColor Gray
    
    Write-Log "Backup complete: $backupDir ($($BackupStats.TotalSize) KB)" $LogPath
}
catch {
    Write-Log "Error during backup: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
