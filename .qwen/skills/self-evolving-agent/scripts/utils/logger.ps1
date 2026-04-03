#Requires -Version 5.1
<#
.SYNOPSIS
    Logging utility for self-evolving-agent scripts
.DESCRIPTION
    Provides structured logging with levels, rotation, and formatting
#>

param()

# Prevent multiple definitions
if (Get-Variable -Name "LoggerLoaded" -ErrorAction SilentlyContinue) { return }
$Global:LoggerLoaded = $true

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$true)]
        [string]$LogPath,
        
        [ValidateSet('Debug', 'Info', 'Warning', 'Error', 'Fatal')]
        [string]$Level = 'Info',
        
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $levelColor = switch ($Level) {
        'Debug'   { 'Gray' }
        'Info'    { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Fatal'   { 'Red' }
    }
    
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to file
    try {
        $logDir = Split-Path -Parent $LogPath
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
    }
    catch {
        Write-Host "Failed to write to log: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Write to console (unless suppressed)
    if (-not $NoConsole) {
        Write-Host $logEntry -ForegroundColor $levelColor
    }
}

function Get-LogContent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LogPath,
        
        [int]$LastN = 100
    )
    
    if (Test-Path $LogPath) {
        Get-Content $LogPath | Select-Object -Last $LastN
    } else {
        Write-Host "Log file not found: $LogPath" -ForegroundColor Yellow
        return @()
    }
}

function Clear-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LogPath
    )
    
    if (Test-Path $LogPath) {
        Clear-Content $LogPath
        Write-Host "Cleared log: $LogPath" -ForegroundColor Gray
    }
}

function Rotate-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LogPath,
        
        [int]$MaxLines = 1000,
        
        [int]$MaxArchives = 5
    )
    
    if (-not (Test-Path $LogPath)) { return }
    
    $lines = Get-Content $LogPath
    if ($lines.Count -gt $MaxLines) {
        # Archive old log
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $archivePath = "$LogPath.$timestamp"
        
        # Keep only last MaxLines
        $lines | Select-Object -Last $MaxLines | Set-Content $LogPath -Encoding UTF8
        
        # Move old content to archive
        $lines | Select-Object -First ($lines.Count - $MaxLines) | Set-Content $archivePath -Encoding UTF8
        
        Write-Host "Rotated log: $LogPath -> $archivePath" -ForegroundColor Gray
        
        # Clean old archives
        $baseName = Split-Path -Leaf $LogPath
        $dir = Split-Path -Parent $LogPath
        $archives = Get-ChildItem -Path $dir -Filter "$baseName.*" | Sort-Object -Property LastWriteTime
        
        if ($archives.Count -gt $MaxArchives) {
            $archives[0..($archives.Count - $MaxArchives - 1)] | Remove-Item -Force
            Write-Host "Cleaned old log archives" -ForegroundColor Gray
        }
    }
}

# Don't export when dot-sourced (for script use)
# Export-ModuleMember -Function Write-Log, Get-LogContent, Clear-Log, Rotate-Log
