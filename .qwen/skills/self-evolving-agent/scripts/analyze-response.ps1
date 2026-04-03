#Requires -Version 5.1
<#
.SYNOPSIS
    Analyzes the last agent response for learning opportunities
.DESCRIPTION
    Examines the most recent agent response to identify:
    - User corrections or feedback
    - Errors or misunderstandings
    - Successful patterns to reinforce
    - Knowledge gaps to address
.PARAMETER LastN
    Number of recent responses to analyze (default: 1)
.PARAMETER OutputFormat
    Output format: Console, File, or Both (default: Both)
.EXAMPLE
    .\analyze-response.ps1
.EXAMPLE
    .\analyze-response.ps1 -LastN 5 -OutputFormat Console
#>

param(
    [int]$LastN = 1,
    [ValidateSet('Console', 'File', 'Both')]
    [string]$OutputFormat = 'Both'
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\response-analysis.log"
$LearningsPath = "$ScriptDir\..\knowledge\pending-learnings.json"
$MemoryDir = "$PSScriptRoot\..\..\..\remember\logs\autonomous"

Write-Log "Starting response analysis" $LogPath

try {
    # Get recent conversation history
    $ConversationHistory = Get-RecentConversationHistory -Count $LastN
    
    if (-not $ConversationHistory) {
        Write-Log "No conversation history found" $LogPath -Level Warning
        exit 0
    }
    
    $Learnings = @()
    
    foreach ($response in $ConversationHistory) {
        Write-Log "Analyzing response from $($response.Timestamp)" $LogPath
        
        # Detect user feedback patterns
        $FeedbackPatterns = @(
            @{ Pattern = "No, that's wrong"; Type = "Correction"; Priority = "High" },
            @{ Pattern = "Actually"; Type = "Correction"; Priority = "Medium" },
            @{ Pattern = "Not quite"; Type = "Correction"; Priority = "Medium" },
            @{ Pattern = "I said"; Type = "Clarification"; Priority = "Medium" },
            @{ Pattern = "Remember that"; Type = "Preference"; Priority = "Low" },
            @{ Pattern = "Always"; Type = "Preference"; Priority = "Medium" },
            @{ Pattern = "Never"; Type = "Correction"; Priority = "High" },
            @{ Pattern = "That worked"; Type = "Success"; Priority = "Low" },
            @{ Pattern = "Perfect"; Type = "Success"; Priority = "Low" },
            @{ Pattern = "Thanks"; Type = "Success"; Priority = "Low" },
            @{ Pattern = "Error"; Type = "Error"; Priority = "High" },
            @{ Pattern = "Failed"; Type = "Error"; Priority = "High" },
            @{ Pattern = "doesn't work"; Type = "Error"; Priority = "High" }
        )
        
        $UserMessage = $response.UserMessage
        $AgentResponse = $response.AgentResponse
        
        foreach ($pattern in $FeedbackPatterns) {
            if ($UserMessage -match $pattern.Pattern) {
                Write-Log "Detected $($pattern.Type): $($pattern.Pattern)" $LogPath
                
                $learning = [PSCustomObject]@{
                    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                    Category = $pattern.Type
                    Topic = "Auto-detected"
                    Context = $UserMessage.Substring(0, [Math]::Min(200, $UserMessage.Length))
                    Observation = "User feedback detected: $($pattern.Pattern)"
                    Insight = "Pending analysis"
                    Action = "Review and extract specific learning"
                    AppliesTo = @()
                    Priority = $pattern.Priority
                    Source = "ResponseAnalysis"
                    Status = "Pending"
                }
                
                $Learnings += $learning
            }
        }
        
        # Detect error patterns in agent response
        if ($AgentResponse -match "(?i)(error|exception|failed|couldn't|unable to)") {
            Write-Log "Detected error in agent response" $LogPath
            
            $learning = [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                Category = "Error"
                Topic = "Auto-detected"
                Context = $AgentResponse.Substring(0, [Math]::Min(200, $AgentResponse.Length))
                Observation = "Agent encountered error or failure"
                Insight = "Pending root cause analysis"
                Action = "Analyze error and create prevention strategy"
                AppliesTo = @()
                Priority = "High"
                Source = "ResponseAnalysis"
                Status = "Pending"
            }
            
            $Learnings += $learning
        }
    }
    
    # Save learnings
    if ($Learnings.Count -gt 0) {
        Write-Log "Found $($Learnings.Count) potential learnings" $LogPath
        
        # Load existing pending learnings
        $ExistingLearnings = @()
        if (Test-Path $LearningsPath) {
            $ExistingLearnings = Get-Content $LearningsPath -Raw | ConvertFrom-Json
        }
        
        # Merge and deduplicate
        $AllLearnings = $ExistingLearnings + $Learnings
        $UniqueLearnings = $AllLearnings | Sort-Object -Property Timestamp -Unique
        
        # Save
        $UniqueLearnings | ConvertTo-Json -Depth 10 | Set-Content $LearningsPath -Encoding UTF8
        
        if ($OutputFormat -eq 'Console' -or $OutputFormat -eq 'Both') {
            Write-Host "`n=== Response Analysis Results ===" -ForegroundColor Cyan
            Write-Host "Found $($Learnings.Count) potential learning(s)" -ForegroundColor Green
            Write-Host "Saved to: $LearningsPath" -ForegroundColor Gray
        }
        
        if ($OutputFormat -eq 'File' -or $OutputFormat -eq 'Both') {
            Write-Log "Analysis complete. Found $($Learnings.Count) learnings" $LogPath
        }
        
        # Trigger integration if we have high-priority items
        $HighPriority = $Learnings | Where-Object { $_.Priority -eq 'High' }
        if ($HighPriority.Count -gt 0) {
            Write-Log "High-priority learnings detected. Triggering immediate integration." $LogPath
            & "$ScriptDir\integrate-knowledge.ps1" -Priority High
        }
    } else {
        Write-Log "No new learnings detected" $LogPath
        
        if ($OutputFormat -eq 'Console' -or $OutputFormat -eq 'Both') {
            Write-Host "`n=== Response Analysis Results ===" -ForegroundColor Cyan
            Write-Host "No new learnings detected" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Log "Error during response analysis: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Log "Response analysis complete" $LogPath
