#Requires -Version 5.1
<#
.SYNOPSIS
    Identifies knowledge gaps from recent learnings
.DESCRIPTION
    Analyzes pending learnings to identify:
    - Missing information that would have helped
    - Outdated knowledge that caused issues
    - Skills that need enhancement
    - Documentation that needs fetching
.EXAMPLE
    .\identify-gaps.ps1
#>

param()

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\gap-analysis.log"
$LearningsPath = "$ScriptDir\..\knowledge\pending-learnings.json"
$GapsPath = "$ScriptDir\..\knowledge\identified-gaps.json"

Write-Log "Starting knowledge gap analysis" $LogPath

try {
    # Get pending learnings
    $PendingLearnings = @()
    if (Test-Path $LearningsPath) {
        $PendingLearnings = Read-JsonFile -Path $LearningsPath -ReturnEmptyIfMissing
    }
    
    if ($PendingLearnings.Count -eq 0) {
        Write-Log "No pending learnings to analyze" $LogPath
        Write-Host "No pending learnings to analyze" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Log "Analyzing $($PendingLearnings.Count) learning(s)" $LogPath
    
    $Gaps = @()
    
    foreach ($learning in $PendingLearnings) {
        # Analyze for knowledge gaps
        $gap = Analyze-LearningForGaps -Learning $learning
        
        if ($gap) {
            $Gaps += $gap
        }
    }
    
    # Deduplicate gaps
    if ($Gaps.Count -gt 0) {
        $UniqueGaps = $Gaps | Sort-Object -Property @{Expression = {$_.Category + "_" + $_.Topic}} -Unique
        
        # Save gaps
        Write-JsonFile -Path $GapsPath -Data $UniqueGaps -Backup:$true
        
        Write-Host "`n=== Knowledge Gap Analysis ===" -ForegroundColor Cyan
        Write-Host "Identified $($UniqueGaps.Count) knowledge gap(s):" -ForegroundColor Yellow
        
        foreach ($gap in $UniqueGaps) {
            Write-Host "  - [$($gap.Category)] $($gap.Topic)" -ForegroundColor Gray
            Write-Host "    Action: $($gap.RecommendedAction)" -ForegroundColor DarkGray
        }
        
        Write-Log "Identified $($UniqueGaps.Count) knowledge gap(s)" $LogPath
    } else {
        Write-Host "No knowledge gaps identified" -ForegroundColor Green
    }
}
catch {
    Write-Log "Error during gap analysis: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Log "Gap analysis complete" $LogPath

function Analyze-LearningForGaps {
    param(
        [PSCustomObject]$Learning
    )
    
    $topic = $Learning.Topic.ToLower()
    $category = $Learning.Category
    $insight = $Learning.Insight
    
    # Determine gap category
    if ($topic -match "flutter|widget|state") {
        return @{
            Category = "Flutter"
            Topic = $Learning.Topic
            Description = "Flutter-related knowledge gap detected"
            RecommendedAction = "Fetch Flutter documentation"
            Priority = $Learning.Priority
            Source = $Learning.Source
        }
    }
    elseif ($topic -match "dart|async|null") {
        return @{
            Category = "Dart"
            Topic = $Learning.Topic
            Description = "Dart language knowledge gap detected"
            RecommendedAction = "Fetch Dart documentation"
            Priority = $Learning.Priority
            Source = $Learning.Source
        }
    }
    elseif ($topic -match "package|dependency|pub") {
        return @{
            Category = "Package"
            Topic = $Learning.Topic
            Description = "Package knowledge gap detected"
            RecommendedAction = "Fetch package documentation"
            Priority = $Learning.Priority
            Source = $Learning.Source
        }
    }
    elseif ($category -eq "Error" -and $insight -match "outdated|deprecated") {
        return @{
            Category = "Outdated"
            Topic = $Learning.Topic
            Description = "Outdated knowledge detected"
            RecommendedAction = "Refresh documentation"
            Priority = "High"
            Source = $Learning.Source
        }
    }
    
    return $null
}
