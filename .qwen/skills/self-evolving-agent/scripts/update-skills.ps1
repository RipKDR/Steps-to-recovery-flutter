#Requires -Version 5.1
<#
.SYNOPSIS
    Updates all installed skills with new knowledge
.DESCRIPTION
    Scans all skills in .qwen/skills/, analyzes pending learnings,
    and updates skill files with improved knowledge and patterns.
.PARAMETER All
    Update all skills
.PARAMETER SkillName
    Update specific skill by name
.PARAMETER Force
    Force update even if no new learnings
.PARAMETER DryRun
    Show what would be updated without making changes
.EXAMPLE
    .\update-skills.ps1 -All
.EXAMPLE
    .\update-skills.ps1 -SkillName "flutter-expert"
.EXAMPLE
    .\update-skills.ps1 -All -DryRun
#>

param(
    [switch]$All,
    [string]$SkillName,
    [switch]$Force,
    [switch]$DryRun
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"
. "$ScriptDir\utils\json-helpers.ps1"
. "$ScriptDir\utils\git-helpers.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\skill-updates.log"
$LearningsPath = "$ScriptDir\..\knowledge\pending-learnings.json"
$SkillsDir = "$PSScriptRoot\..\..\.."
$BackupDir = "$ScriptDir\..\backups\skills"

Write-Log "Starting skill update process" $LogPath

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
    
    # Get list of skills to update
    $SkillsToUpdate = @()
    
    if ($All) {
        $SkillsToUpdate = Get-ChildItem -Path $SkillsDir -Directory | 
                          Where-Object { $_.Name -ne "self-evolving-agent" } |
                          Select-Object -ExpandProperty Name
    }
    elseif ($SkillName) {
        if (Test-Path "$SkillsDir\$SkillName") {
            $SkillsToUpdate = @($SkillName)
        } else {
            Write-Log "Skill not found: $SkillName" $LogPath -Level Error
            Write-Host "Skill not found: $SkillName" -ForegroundColor Red
            exit 1
        }
    } else {
        # Auto-detect skills based on learnings
        $SkillsToUpdate = $PendingLearnings.AppliesTo | 
                          Where-Object { $_ -match "\.qwen\\skills\\" } |
                          ForEach-Object { ($_ -split "\\")[-2] } |
                          Select-Object -Unique
    }
    
    if ($SkillsToUpdate.Count -eq 0) {
        Write-Log "No skills to update" $LogPath
        Write-Host "No skills to update" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Log "Updating $($SkillsToUpdate.Count) skill(s): $($SkillsToUpdate -join ', ')" $LogPath
    
    $UpdatedSkills = @()
    
    foreach ($skill in $SkillsToUpdate) {
        Write-Log "Processing skill: $skill" $LogPath
        
        $SkillPath = "$SkillsDir\$skill"
        $SkillFile = "$SkillPath\SKILL.md"
        
        if (-not (Test-Path $SkillFile)) {
            Write-Log "No SKILL.md found for $skill - skipping" $LogPath -Level Warning
            continue
        }
        
        # Create backup
        if (-not $DryRun) {
            if (-not (Test-Path $BackupDir)) {
                New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
            }
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            Copy-Item -Path $SkillFile -Destination "$BackupDir\$skill.$timestamp.bak" -Force
            Write-Log "Backed up $skill" $LogPath
        }
        
        # Get relevant learnings for this skill
        $RelevantLearnings = $PendingLearnings | Where-Object {
            $_.AppliesTo -like "*$skill*" -or 
            $_.Category -eq "Success" -or
            $_.Source -eq "SkillImprovement"
        }
        
        if ($RelevantLearnings.Count -eq 0 -and -not $Force) {
            Write-Log "No relevant learnings for $skill" $LogPath
            continue
        }
        
        # Read current skill content
        $SkillContent = Get-Content $SkillFile -Raw -Encoding UTF8
        
        # Generate improvements based on learnings
        $Improvements = @()
        
        foreach ($learning in $RelevantLearnings) {
            $improvement = Generate-SkillImprovement -Learning $learning -SkillName $skill
            if ($improvement) {
                $Improvements += $improvement
            }
        }
        
        if ($Improvements.Count -eq 0 -and -not $Force) {
            Write-Log "No improvements generated for $skill" $LogPath
            continue
        }
        
        # Apply improvements
        if (-not $DryRun) {
            $UpdatedContent = Apply-SkillImprovements -Content $SkillContent -Improvements $Improvements
            
            # Write updated content
            [System.IO.File]::WriteAllText(
                [System.IO.Path]::GetFullPath($SkillFile),
                $UpdatedContent,
                [System.Text.UTF8Encoding]::new($false)
            )
            
            Write-Log "Updated skill: $skill" $LogPath
            $UpdatedSkills += $skill
        } else {
            Write-Host "`n[DRY RUN] Would update skill: $skill" -ForegroundColor Cyan
            Write-Host "Improvements: $($Improvements.Count)" -ForegroundColor Gray
        }
    }
    
    # Mark processed learnings as integrated
    if ($UpdatedSkills.Count -gt 0 -and -not $DryRun) {
        $RemainingLearnings = $PendingLearnings | Where-Object {
            $_.Status -ne "Integrated"
        }
        
        Write-JsonFile -Path $LearningsPath -Data $RemainingLearnings -Backup:$true
        
        # Commit changes
        if (Test-GitAvailable) {
            $message = "chore(skills): auto-update $($UpdatedSkills.Count) skill(s) with new learnings"
            Add-FilesToGit @("$SkillsDir")
            Commit-Git -Message $message
            Write-Log "Committed skill updates" $LogPath
        }
    }
    
    # Summary
    Write-Host "`n=== Skill Update Summary ===" -ForegroundColor Cyan
    Write-Host "Updated $($UpdatedSkills.Count) skill(s):" -ForegroundColor Green
    $UpdatedSkills | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    
    if ($DryRun) {
        Write-Host "`n[DRY RUN] No changes were made" -ForegroundColor Yellow
    }
}
catch {
    Write-Log "Error during skill update: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Log "Skill update complete" $LogPath

function Generate-SkillImprovement {
    param(
        [PSCustomObject]$Learning,
        [string]$SkillName
    )
    
    # Generate improvement based on learning category
    switch ($Learning.Category) {
        'Correction' {
            return @{
                Type = 'AddCorrection'
                Section = 'Common Mistakes'
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
                Content = "- **$($Learning.Topic)**: $($Learning.Insight)"
            }
        }
        'Preference' {
            return @{
                Type = 'AddPreference'
                Section = 'User Preferences'
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

function Apply-SkillImprovements {
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
