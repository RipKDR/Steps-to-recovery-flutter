#Requires -Version 5.1
<#
.SYNOPSIS
    Updates all agent definitions with new knowledge
.DESCRIPTION
    Scans all agents in .qwen/agents/, analyzes pending learnings,
    and updates agent files with improved capabilities and behaviors.
.PARAMETER All
    Update all agents
.PARAMETER AgentName
    Update specific agent by name
.PARAMETER Force
    Force update even if no new learnings
.PARAMETER DryRun
    Show what would be updated without making changes
.EXAMPLE
    .\update-agents.ps1 -All
.EXAMPLE
    .\update-agents.ps1 -AgentName "flutter-widget-builder"
.EXAMPLE
    .\update-agents.ps1 -All -DryRun
#>

param(
    [switch]$All,
    [string]$AgentName,
    [switch]$Force,
    [switch]$DryRun
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\agent-updates.log"
$LearningsPath = "$ScriptDir\..\knowledge\pending-learnings.json"
$AgentsDir = "$PSScriptRoot\..\..\agents"
$BackupDir = "$ScriptDir\..\backups\agents"

Write-Log "Starting agent update process" $LogPath

try {
    # Get pending learnings
    $PendingLearnings = @()
    if (Test-Path $LearningsPath) {
        $PendingLearnings = Read-JsonFile -Path $LearningsPath -ReturnEmptyIfMissing
        Write-Log "Found $($PendingLearnings.Count) pending learning(s)" $LogPath
    }
    
    if ($PendingLearnings.Count -eq 0 -and -not $Force) {
        Write-Log "No pending learnings. Use -Force to update anyway." $LogPath
        Write-Host "No pending learnings to integrate. Use -Force to update anyway." -ForegroundColor Yellow
        exit 0
    }
    
    # Get list of agents to update
    $AgentsToUpdate = @()
    
    if ($All) {
        $AgentsToUpdate = Get-ChildItem -Path $AgentsDir -Filter "*.md" | 
                          Select-Object -ExpandProperty BaseName
    }
    elseif ($AgentName) {
        $agentFile = "$AgentsDir\$AgentName.md"
        if (Test-Path $agentFile) {
            $AgentsToUpdate = @($AgentName)
        } else {
            Write-Log "Agent not found: $AgentName" $LogPath -Level Error
            Write-Host "Agent not found: $AgentName" -ForegroundColor Red
            exit 1
        }
    } else {
        # Auto-detect agents based on learnings
        $AgentsToUpdate = $PendingLearnings.AppliesTo | 
                          Where-Object { $_ -match "\.qwen\\agents\\" } |
                          ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) } |
                          Select-Object -Unique
    }
    
    if ($AgentsToUpdate.Count -eq 0) {
        Write-Log "No agents to update" $LogPath
        Write-Host "No agents to update" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Log "Updating $($AgentsToUpdate.Count) agent(s): $($AgentsToUpdate -join ', ')" $LogPath
    
    $UpdatedAgents = @()
    
    foreach ($agent in $AgentsToUpdate) {
        Write-Log "Processing agent: $agent" $LogPath
        
        $AgentPath = "$AgentsDir\$agent.md"
        
        if (-not (Test-Path $AgentPath)) {
            Write-Log "No agent file found for $agent - skipping" $LogPath -Level Warning
            continue
        }
        
        # Create backup
        if (-not $DryRun) {
            if (-not (Test-Path $BackupDir)) {
                New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
            }
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            Copy-Item -Path $AgentPath -Destination "$BackupDir\$agent.$timestamp.bak" -Force
            Write-Log "Backed up agent: $agent" $LogPath
        }
        
        # Get relevant learnings for this agent
        $RelevantLearnings = $PendingLearnings | Where-Object {
            $_.AppliesTo -like "*$agent*" -or 
            $_.Category -eq "AgentImprovement" -or
            $_.Source -eq "AgentPerformance"
        }
        
        if ($RelevantLearnings.Count -eq 0 -and -not $Force) {
            Write-Log "No relevant learnings for agent: $agent" $LogPath
            continue
        }
        
        # Read current agent content
        $AgentContent = Get-Content $AgentPath -Raw -Encoding UTF8
        
        # Generate improvements based on learnings
        $Improvements = @()
        
        foreach ($learning in $RelevantLearnings) {
            $improvement = Generate-AgentImprovement -Learning $learning -AgentName $agent
            if ($improvement) {
                $Improvements += $improvement
            }
        }
        
        if ($Improvements.Count -eq 0 -and -not $Force) {
            Write-Log "No improvements generated for agent: $agent" $LogPath
            continue
        }
        
        # Apply improvements
        if (-not $DryRun) {
            $UpdatedContent = Apply-AgentImprovements -Content $AgentContent -Improvements $Improvements
            
            # Write updated content
            [System.IO.File]::WriteAllText(
                [System.IO.Path]::GetFullPath($AgentPath),
                $UpdatedContent,
                [System.Text.UTF8Encoding]::new($false)
            )
            
            Write-Log "Updated agent: $agent" $LogPath
            $UpdatedAgents += $agent
        } else {
            Write-Host "`n[DRY RUN] Would update agent: $agent" -ForegroundColor Cyan
            Write-Host "Improvements: $($Improvements.Count)" -ForegroundColor Gray
        }
    }
    
    # Mark processed learnings as integrated
    if ($UpdatedAgents.Count -gt 0 -and -not $DryRun) {
        $RemainingLearnings = $PendingLearnings | Where-Object {
            $_.Status -ne "Integrated"
        }
        
        Write-JsonFile -Path $LearningsPath -Data $RemainingLearnings -Backup:$true
        
        # Commit changes
        if (Test-GitAvailable) {
            $message = "chore(agents): auto-update $($UpdatedAgents.Count) agent(s) with new learnings"
            Add-FilesToGit @("$AgentsDir")
            Commit-Git -Message $message
            Write-Log "Committed agent updates" $LogPath
        }
    }
    
    # Summary
    Write-Host "`n=== Agent Update Summary ===" -ForegroundColor Cyan
    Write-Host "Updated $($UpdatedAgents.Count) agent(s):" -ForegroundColor Green
    $UpdatedAgents | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    
    if ($DryRun) {
        Write-Host "`n[DRY RUN] No changes were made" -ForegroundColor Yellow
    }
}
catch {
    Write-Log "Error during agent update: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Log "Agent update complete" $LogPath

function Generate-AgentImprovement {
    param(
        [PSCustomObject]$Learning,
        [string]$AgentName
    )
    
    # Generate improvement based on learning category
    switch ($Learning.Category) {
        'Correction' {
            return @{
                Type = 'AddCapability'
                Section = 'Capabilities'
                Content = "- **$($Learning.Topic)**: $($Learning.Insight)"
            }
        }
        'Success' {
            return @{
                Type = 'AddBestPractice'
                Section = 'Best Practices'
                Content = "- **$($Learning.Topic)**: $($Learning.Insight)"
            }
        }
        'Error' {
            return @{
                Type = 'AddErrorHandling'
                Section = 'Error Handling'
                Content = "- **$($Learning.Topic)**: Prevention: $($Learning.Insight)"
            }
        }
        'AgentImprovement' {
            return @{
                Type = 'AddCapability'
                Section = 'Capabilities'
                Content = "- **$($Learning.Topic)**: $($Learning.Insight)"
            }
        }
        default {
            return @{
                Type = 'AddNote'
                Section = 'Notes'
                Content = "- **$($Learning.Topic)**: $($Learning.Insight)"
            }
        }
    }
}

function Apply-AgentImprovements {
    param(
        [string]$Content,
        [Array]$Improvements
    )
    
    $UpdatedContent = $Content
    
    foreach ($improvement in $Improvements) {
        # Find or create section
        $sectionPattern = "## $($improvement.Section)"
        
        if ($UpdatedContent -match [regex]::Escape($sectionPattern)) {
            # Insert after section header
            $UpdatedContent = $UpdatedContent -replace 
                "($sectionPattern\r?\n)",
                "`$1`r`n$($improvement.Content)`r`n"
        } else {
            # Add new section before last header
            $newSection = @"

## $($improvement.Section)

$($improvement.Content)

"@
            $UpdatedContent = $UpdatedContent -replace 
                "(## [^\r\n]+\r?\n[^$]+)$",
                "`$1$newSection"
        }
    }
    
    # Update version/timestamp
    $UpdatedContent = $UpdatedContent -replace 
        '\*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}',
        "**Last Updated:** $(Get-Date -Format 'yyyy-MM-dd')"
    
    return $UpdatedContent
}
