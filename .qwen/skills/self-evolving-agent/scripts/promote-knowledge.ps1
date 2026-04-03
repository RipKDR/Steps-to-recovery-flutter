#Requires -Version 5.1
<#
.SYNOPSIS
    Promotes important learnings to configuration files
.DESCRIPTION
    Identifies high-value learnings and promotes them to:
    - AGENTS.md
    - CLAUDE.md / QWEN.md
    - USER.md
    - project-state.md
.PARAMETER Force
    Force promote even if low priority
.EXAMPLE
    .\promote-knowledge.ps1
.EXAMPLE
    .\promote-knowledge.ps1 -Force
#>

param(
    [switch]$Force
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\promote-knowledge.log"
$ProjectRoot = "$PSScriptRoot\..\..\..\.."

Write-Log "Starting knowledge promotion" $LogPath

try {
    # Get integrated learnings
    $learningsFile = "$ScriptDir\..\knowledge\general-learnings.json"
    $Learnings = @()
    
    if (Test-Path $learningsFile) {
        $Learnings = Read-JsonFile -Path $learningsFile -ReturnEmptyIfMissing
    }
    
    if ($Learnings.Count -eq 0) {
        Write-Log "No learnings to promote" $LogPath
        Write-Host "No learnings to promote" -ForegroundColor Yellow
        exit 0
    }
    
    # Filter for high-priority learnings
    $HighPriority = $Learnings | Where-Object {
        $_.Priority -eq 'High' -or $_.Priority -eq 'Critical' -or $Force
    }
    
    if ($HighPriority.Count -eq 0) {
        Write-Log "No high-priority learnings to promote" $LogPath
        Write-Host "No high-priority learnings to promote" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Log "Promoting $($HighPriority.Count) high-priority learning(s)" $LogPath
    
    $PromotedCount = 0
    
    foreach ($learning in $HighPriority) {
        if ($learning.Status -eq 'Promoted') { continue }
        
        # Determine target file based on learning content
        $targetFile = Get-PromotionTarget -Learning $learning -ProjectRoot $ProjectRoot
        
        if ($targetFile) {
            Promote-Learning -Learning $learning -TargetFile $targetFile
            $learning.Status = 'Promoted'
            $learning.PromotedAt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            $PromotedCount++
        }
    }
    
    # Update learnings file
    Write-JsonFile -Path $learningsFile -Data $Learnings -Backup:$true
    
    # Commit changes
    if (Test-GitAvailable) {
        $message = "chore(config): promote $PromotedCount learning(s) to config files"
        Add-FilesToGit @("$ProjectRoot\AGENTS.md", "$ProjectRoot\QWEN.md")
        Commit-Git -Message $message
    }
    
    Write-Host "`n=== Knowledge Promotion Summary ===" -ForegroundColor Cyan
    Write-Host "Promoted $PromotedCount learning(s) to configuration files" -ForegroundColor Green
    
    Write-Log "Knowledge promotion complete" $LogPath
}
catch {
    Write-Log "Error during knowledge promotion: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

function Get-PromotionTarget {
    param(
        [PSCustomObject]$Learning,
        [string]$ProjectRoot
    )
    
    $topic = $Learning.Topic.ToLower()
    $category = $Learning.Category
    
    # Route based on topic
    if ($topic -match "agent|skill|capability") {
        return "$ProjectRoot\AGENTS.md"
    }
    elseif ($topic -match "user|preference|style") {
        return "$ProjectRoot\QWEN.md"
    }
    elseif ($topic -match "project|app|steps") {
        return "$ProjectRoot\QWEN.md"
    }
    elseif ($category -eq 'Correction') {
        return "$ProjectRoot\AGENTS.md"
    }
    
    return $null
}

function Promote-Learning {
    param(
        [PSCustomObject]$Learning,
        [string]$TargetFile
    )
    
    if (-not (Test-Path $TargetFile)) {
        Write-Host "  Target file not found: $TargetFile" -ForegroundColor Yellow
        return
    }
    
    $entry = "`n<!-- Auto-Promoted Learning $(Get-Date -Format 'yyyy-MM-dd') -->`n" +
             "- **$($Learning.Topic)**: $($Learning.Insight)`n"
    
    $content = Get-Content $TargetFile -Raw -Encoding UTF8
    
    # Find appropriate section to insert
    if ($TargetFile -match "AGENTS\.md") {
        # Insert before last section
        if ($content -match "(## [^\r\n]+)`r?\n`r?\n([^$]+)$") {
            $insertPos = $matches[0].Length
            $content = $content.Insert($insertPos, $entry)
        }
    }
    elseif ($TargetFile -match "QWEN\.md") {
        # Insert in user expectations or project section
        if ($content -match "(## 🎯 User Expectations)") {
            $content = $content -replace 
                "(## 🎯 User Expectations)",
                "$entry`n`n## 🎯 User Expectations"
        }
    }
    
    Set-Content -Path $TargetFile -Value $content -Encoding UTF8
    Write-Host "  Promoted to: $TargetFile" -ForegroundColor Gray
}
