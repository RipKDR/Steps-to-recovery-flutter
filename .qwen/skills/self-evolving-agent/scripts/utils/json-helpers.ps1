#Requires -Version 5.1
<#
.SYNOPSIS
    JSON manipulation utilities for self-evolving-agent
.DESCRIPTION
    Provides helper functions for JSON operations, validation, and transformation
#>

param()

# Prevent multiple definitions
if (Get-Variable -Name "JsonHelpersLoaded" -ErrorAction SilentlyContinue) { return }
$Global:JsonHelpersLoaded = $true

function Get-RecentConversationHistory {
    param(
        [int]$Count = 1
    )
    
    # Try to get conversation from Qwen Code session history
    # This is a placeholder - actual implementation depends on Qwen Code API
    $conversationDir = "$PSScriptRoot\..\..\..\..\.qwen\logs"
    
    if (Test-Path $conversationDir) {
        $latestLog = Get-ChildItem -Path $conversationDir -Filter "*.log" | 
                     Sort-Object -Property LastWriteTime -Descending | 
                     Select-Object -First 1
        
        if ($latestLog) {
            # Parse conversation log (format depends on Qwen Code)
            $content = Get-Content $latestLog.FullName -Raw
            
            # Extract user messages and agent responses
            # This is a simplified parser - adjust based on actual format
            $messages = @()
            $lines = $content -split "`n"
            
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "^\[(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})\]\s*User:") {
                    $timestamp = $matches[1]
                    $userMessage = $lines[$i] -replace "^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\]\s*User:\s*", ""
                    
                    # Find next agent response
                    for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                        if ($lines[$j] -match "^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\]\s*Agent:") {
                            $agentResponse = $lines[$j] -replace "^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\]\s*Agent:\s*", ""
                            
                            $messages += [PSCustomObject]@{
                                Timestamp = $timestamp
                                UserMessage = $userMessage.Trim()
                                AgentResponse = $agentResponse.Trim()
                            }
                            
                            break
                        }
                    }
                }
            }
            
            return $messages | Select-Object -Last $Count
        }
    }
    
    # Fallback: Check for conversation export file
    $exportFile = "$PSScriptRoot\..\..\..\..\.qwen\conversation.json"
    if (Test-Path $exportFile) {
        $data = Get-Content $exportFile -Raw | ConvertFrom-Json
        return $data.messages | Select-Object -Last $Count
    }
    
    return $null
}

function ConvertTo-LearningEntry {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Data
    )
    
    # Validate required fields
    $requiredFields = @('Timestamp', 'Category', 'Topic', 'Context', 'Observation', 'Insight', 'Action', 'Priority')
    $missingFields = @()
    
    foreach ($field in $requiredFields) {
        if (-not $Data.PSObject.Properties.Name -contains $field) {
            $missingFields += $field
        }
    }
    
    if ($missingFields.Count -gt 0) {
        throw "Missing required fields: $($missingFields -join ', ')"
    }
    
    # Set defaults for optional fields
    if (-not $Data.AppliesTo) { $Data.AppliesTo = @() }
    if (-not $Data.Source) { $Data.Source = "Manual" }
    if (-not $Data.Status) { $Data.Status = "New" }
    
    return $Data
}

function Merge-LearningEntries {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$Existing,
        
        [Parameter(Mandatory=$true)]
        [Array]$New
    )
    
    # Combine and deduplicate by timestamp + topic
    $all = $Existing + $New
    $unique = $all | Sort-Object -Property @{Expression = {$_.Timestamp + $_.Topic}} -Unique
    
    return $unique
}

function Test-JsonFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        return $false
    }
    
    try {
        $content = Get-Content $Path -Raw -ErrorAction Stop
        $null = $content | ConvertFrom-Json -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Read-JsonFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [switch]$ReturnEmptyIfMissing
    )
    
    if (-not (Test-Path $Path)) {
        if ($ReturnEmptyIfMissing) {
            return @()
        }
        throw "File not found: $Path"
    }
    
    try {
        $content = Get-Content $Path -Raw -Encoding UTF8
        return $content | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in $Path`: $($_.Exception.Message)"
    }
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$true)]
        [Object]$Data,
        
        [int]$Depth = 10,
        
        [switch]$Backup
    )
    
    # Backup existing file if requested
    if ($Backup -and (Test-Path $Path)) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupPath = "$Path.$timestamp.bak"
        Copy-Item -Path $Path -Destination $backupPath -Force
    }
    
    # Ensure directory exists
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    # Write with proper formatting
    $json = $Data | ConvertTo-Json -Depth $Depth -Compress:$false
    [System.IO.File]::WriteAllText(
        [System.IO.Path]::GetFullPath($Path),
        $json,
        [System.Text.UTF8Encoding]::new($false)
    )
}

function Format-JsonFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (Test-Path $Path) {
        $data = Read-JsonFile -Path $Path
        Write-JsonFile -Path $Path -Data $data
        Write-Host "Formatted: $Path" -ForegroundColor Gray
    }
}

# Don't export when dot-sourced (for script use)
# Export-ModuleMember -Function Get-RecentConversationHistory, ConvertTo-LearningEntry, Merge-LearningEntries, Test-JsonFile, Read-JsonFile, Write-JsonFile, Format-JsonFile
