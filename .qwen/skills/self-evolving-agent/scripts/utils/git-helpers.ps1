#Requires -Version 5.1
<#
.SYNOPSIS
    Git helper utilities for self-evolving-agent
.DESCRIPTION
    Provides Git operations for version control, commits, and rollbacks
#>

param()

# Prevent multiple definitions
if (Get-Variable -Name "GitHelpersLoaded" -ErrorAction SilentlyContinue) { return }
$Global:GitHelpersLoaded = $true

function Test-GitAvailable {
    try {
        $null = git --version 2>&1
        return $true
    }
    catch {
        return $false
    }
}

function Test-GitRepository {
    param(
        [string]$Path = "."
    )
    
    $gitDir = Join-Path $Path ".git"
    return Test-Path $gitDir
}

function Get-GitStatus {
    try {
        $status = git status --porcelain 2>&1
        return $status
    }
    catch {
        return $null
    }
}

function Add-FilesToGit {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$Paths
    )
    
    foreach ($path in $Paths) {
        try {
            git add $path 2>&1 | Out-Null
        }
        catch {
            Write-Host "Failed to add: $path" -ForegroundColor Yellow
        }
    }
}

function Commit-Git {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [string]$Author = "Self-Evolving Agent <agent@steps-to-recovery.local>"
    )
    
    try {
        git -c user.name="$($Author.Split('<')[0].Trim())" `
            -c user.email="$($Author.Split('<')[1].Trim('>'))" `
            commit -m $Message 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Committed: $Message" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Commit failed" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Commit error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Create-GitTag {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TagName,
        
        [string]$Message = ""
    )
    
    try {
        if ($Message) {
            git tag -a $TagName -m $Message 2>&1 | Out-Null
        } else {
            git tag $TagName 2>&1 | Out-Null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Created tag: $TagName" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Tag creation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $false
}

function Get-GitTags {
    try {
        return git tag --sort=-version:refname 2>&1
    }
    catch {
        return @()
    }
}

function Rollback-Git {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Target
    )
    
    # Target can be a commit hash, tag, or relative reference (e.g., HEAD~1)
    try {
        # Soft reset to keep changes staged
        git reset --soft $Target 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Rolled back to: $Target" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Rollback failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $false
}

function Get-GitLog {
    param(
        [string]$Path = "",
        [int]$MaxCount = 20
    )
    
    try {
        $cmd = "git log --oneline -n $MaxCount"
        if ($Path) {
            $cmd += " -- $Path"
        }
        
        return Invoke-Expression $cmd 2>&1
    }
    catch {
        return @()
    }
}

function Get-GitDiff {
    param(
        [string]$From = "HEAD~1",
        [string]$To = "HEAD",
        [string]$Path = ""
    )
    
    try {
        $cmd = "git diff $From $To"
        if ($Path) {
            $cmd += " -- $Path"
        }
        
        return Invoke-Expression $cmd 2>&1
    }
    catch {
        return ""
    }
}

function Create-GitBranch {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BranchName,
        
        [switch]$Checkout
    )
    
    try {
        if ($Checkout) {
            git checkout -b $BranchName 2>&1 | Out-Null
        } else {
            git branch $BranchName 2>&1 | Out-Null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Created branch: $BranchName" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Branch creation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $false
}

function Get-CurrentBranch {
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>&1
        return $branch
    }
    catch {
        return "unknown"
    }
}

function Push-Git {
    param(
        [string]$Remote = "origin",
        [string]$Branch = ""
    )
    
    try {
        $cmd = "git push $Remote"
        if ($Branch) {
            $cmd += " $Branch"
        }
        
        Invoke-Expression $cmd 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pushed successfully" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Push failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $false
}

# Don't export when dot-sourced (for script use)
# Export-ModuleMember -Function Test-GitAvailable, Test-GitRepository, Get-GitStatus, Add-FilesToGit, Commit-Git, Create-GitTag, Get-GitTags, Rollback-Git, Get-GitLog, Get-GitDiff, Create-GitBranch, Get-CurrentBranch, Push-Git
