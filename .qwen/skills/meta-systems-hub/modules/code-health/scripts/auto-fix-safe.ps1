# Auto-Fix Safe Issues
# Automatically fixes safe, non-controversial issues

param(
    [string]$Category = "lint,imports,unused,deprecated",
    [switch]$DryRun,
    [switch]$Silent,
    [switch]$RunTests,
    [switch]$Backup,
    [int]$MaxFixes = 10
)

$ErrorActionPreference = "Continue"

# Colors
$HeaderColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"

# Paths
$CodeHealthPath = ".qwen\skills\meta-systems-hub\modules\code-health"
$LogsPath = "$CodeHealthPath\reports"

# Ensure logs directory exists
if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

# Track fixes
$Fixes = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Category = $Category
    FixesApplied = 0
    FixesFailed = 0
    FilesModified = @()
    BackupsCreated = @()
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Auto-Fix Safe Issues                              ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
    Write-Host "Categories: $Category" -ForegroundColor $InfoColor
    Write-Host "Max Fixes: $MaxFixes" -ForegroundColor $InfoColor
    if ($DryRun) { Write-Host "Mode: DRY RUN (no changes will be applied)" -ForegroundColor $WarningColor }
    Write-Host ""
}

# Create backup if requested
if ($Backup -and -not $DryRun) {
    try {
        $stashName = "auto-fix-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        & git stash push -m $stashName 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            $Fixes.BackupsCreated += $stashName
            if (-not $Silent) { Write-Host "  ✓ Backup created: $stashName" -ForegroundColor $SuccessColor }
        }
    } catch {
        if (-not $Silent) { Write-Host "  ⚠ Could not create backup" -ForegroundColor $WarningColor }
    }
}

# Get current issues
if (-not $Silent) { Write-Host "Analyzing current issues..." -ForegroundColor $InfoColor }
$analyzeOutput = & flutter analyze 2>&1 | Out-String
$lines = $analyzeOutput -split "`n"

# Parse issues by category
$issuesByCategory = @{
    lint = @()
    imports = @()
    unused = @()
    deprecated = @()
}

foreach ($line in $lines) {
    if ($line -match "warning.*?(line \d+, column \d+)") {
        $file = ($line -split ":")[0]
        $message = $line
        
        # Categorize
        if ($message -match "unused") {
            $issuesByCategory.unused += @{ File = $file; Message = $message; Line = $matches[1] }
        } elseif ($message -match "import") {
            $issuesByCategory.imports += @{ File = $file; Message = $message; Line = $matches[1] }
        } elseif ($message -match "deprecated") {
            $issuesByCategory.deprecated += @{ File = $file; Message = $message; Line = $matches[1] }
        } else {
            $issuesByCategory.lint += @{ File = $file; Message = $message; Line = $matches[1] }
        }
    }
}

# Apply fixes by category
$categories = $Category -split ","

# Fix 1: Remove unused imports
if ($categories -contains "imports") {
    if (-not $Silent) { Write-Host "" }
    Write-Host "Fixing: Unused imports..." -ForegroundColor $HeaderColor
    
    $fixed = 0
    foreach ($issue in $issuesByCategory.imports) {
        if ($fixed -ge $MaxFixes) { break }
        
        if ($issue.Message -match "unused_import") {
            $file = $issue.File
            
            if (-not $Silent) {
                Write-Host "  File: $file" -ForegroundColor $InfoColor
                Write-Host "  Issue: $($issue.Message)" -ForegroundColor $WarningColor
            }
            
            if (-not $DryRun) {
                # Try to fix with dart fix
                $fixOutput = & dart fix --apply 2>&1 | Out-String
                
                if ($LASTEXITCODE -eq 0) {
                    $fixed++
                    $Fixes.FixesApplied++
                    if (-not $Fixes.FilesModified.Contains($file)) {
                        $Fixes.FilesModified += $file
                    }
                    if (-not $Silent) { Write-Host "  ✓ Fixed" -ForegroundColor $SuccessColor }
                } else {
                    $Fixes.FixesFailed++
                    if (-not $Silent) { Write-Host "  ✗ Fix failed" -ForegroundColor $ErrorColor }
                }
            } else {
                if (-not $Silent) { Write-Host "  ℹ Would fix (dry run)" -ForegroundColor $InfoColor }
                $fixed++
            }
        }
    }
    
    if (-not $Silent) { Write-Host "  Fixed: $fixed import issues" -ForegroundColor $InfoColor }
}

# Fix 2: Remove unused variables
if ($categories -contains "unused") {
    if (-not $Silent) { Write-Host "" }
    Write-Host "Fixing: Unused variables..." -ForegroundColor $HeaderColor
    
    $fixed = 0
    foreach ($issue in $issuesByCategory.unused) {
        if ($fixed -ge $MaxFixes) { break }
        
        if ($issue.Message -match "unused_(element|field|local_variable)") {
            $file = $issue.File
            
            if (-not $Silent) {
                Write-Host "  File: $file" -ForegroundColor $InfoColor
                Write-Host "  Issue: $($issue.Message)" -ForegroundColor $WarningColor
            }
            
            if (-not $DryRun) {
                # Try to fix with dart fix
                $fixOutput = & dart fix --apply 2>&1 | Out-String
                
                if ($LASTEXITCODE -eq 0) {
                    $fixed++
                    $Fixes.FixesApplied++
                    if (-not $Fixes.FilesModified.Contains($file)) {
                        $Fixes.FilesModified += $file
                    }
                    if (-not $Silent) { Write-Host "  ✓ Fixed" -ForegroundColor $SuccessColor }
                } else {
                    $Fixes.FixesFailed++
                    if (-not $Silent) { Write-Host "  ✗ Fix failed" -ForegroundColor $ErrorColor }
                }
            } else {
                if (-not $Silent) { Write-Host "  ℹ Would fix (dry run)" -ForegroundColor $InfoColor }
                $fixed++
            }
        }
    }
    
    if (-not $Silent) { Write-Host "  Fixed: $fixed unused variable issues" -ForegroundColor $InfoColor }
}

# Fix 3: Update deprecated APIs
if ($categories -contains "deprecated") {
    if (-not $Silent) { Write-Host "" }
    Write-Host "Fixing: Deprecated APIs..." -ForegroundColor $HeaderColor
    
    $fixed = 0
    foreach ($issue in $issuesByCategory.deprecated) {
        if ($fixed -ge $MaxFixes) { break }
        
        if ($issue.Message -match "deprecated") {
            $file = $issue.File
            
            if (-not $Silent) {
                Write-Host "  File: $file" -ForegroundColor $InfoColor
                Write-Host "  Issue: $($issue.Message)" -ForegroundColor $WarningColor
            }
            
            if (-not $DryRun) {
                # Try to fix with dart fix
                $fixOutput = & dart fix --apply 2>&1 | Out-String
                
                if ($LASTEXITCODE -eq 0) {
                    $fixed++
                    $Fixes.FixesApplied++
                    if (-not $Fixes.FilesModified.Contains($file)) {
                        $Fixes.FilesModified += $file
                    }
                    if (-not $Silent) { Write-Host "  ✓ Fixed" -ForegroundColor $SuccessColor }
                } else {
                    $Fixes.FixesFailed++
                    if (-not $Silent) { Write-Host "  ✗ Fix failed" -ForegroundColor $ErrorColor }
                }
            } else {
                if (-not $Silent) { Write-Host "  ℹ Would fix (dry run)" -ForegroundColor $InfoColor }
                $fixed++
            }
        }
    }
    
    if (-not $Silent) { Write-Host "  Fixed: $fixed deprecated API issues" -ForegroundColor $InfoColor }
}

# Fix 4: General lint fixes
if ($categories -contains "lint") {
    if (-not $Silent) { Write-Host "" }
    Write-Host "Fixing: General lint issues..." -ForegroundColor $HeaderColor
    
    $fixed = 0
    foreach ($issue in $issuesByCategory.lint) {
        if ($fixed -ge $MaxFixes) { break }
        
        $file = $issue.File
        
        if (-not $Silent) {
            Write-Host "  File: $file" -ForegroundColor $InfoColor
            Write-Host "  Issue: $($issue.Message)" -ForegroundColor $WarningColor
        }
        
        if (-not $DryRun) {
            # Try to fix with dart fix
            $fixOutput = & dart fix --apply 2>&1 | Out-String
            
            if ($LASTEXITCODE -eq 0) {
                $fixed++
                $Fixes.FixesApplied++
                if (-not $Fixes.FilesModified.Contains($file)) {
                    $Fixes.FilesModified += $file
                }
                if (-not $Silent) { Write-Host "  ✓ Fixed" -ForegroundColor $SuccessColor }
            } else {
                $Fixes.FixesFailed++
                if (-not $Silent) { Write-Host "  ✗ Fix failed" -ForegroundColor $ErrorColor }
            }
        } else {
            if (-not $Silent) { Write-Host "  ℹ Would fix (dry run)" -ForegroundColor $InfoColor }
            $fixed++
        }
    }
    
    if (-not $Silent) { Write-Host "  Fixed: $fixed lint issues" -ForegroundColor $InfoColor }
}

# Run tests if requested
if ($RunTests -and -not $DryRun) {
    if (-not $Silent) { Write-Host "" }
    Write-Host "Running tests to verify fixes..." -ForegroundColor $InfoColor
    
    $testOutput = & flutter test 2>&1 | Out-String
    
    if ($LASTEXITCODE -eq 0) {
        if (-not $Silent) { Write-Host "  ✓ All tests pass" -ForegroundColor $SuccessColor }
        $Fixes.TestsPassed = $true
    } else {
        if (-not $Silent) { Write-Host "  ✗ Some tests failed" -ForegroundColor $ErrorColor }
        $Fixes.TestsPassed = $false
        
        # Offer to rollback
        if ($Fixes.BackupsCreated.Count -gt 0) {
            Write-Host "  Rolling back changes..." -ForegroundColor $WarningColor
            & git stash pop 2>&1 | Out-Null
            Write-Host "  ✓ Changes rolled back" -ForegroundColor $InfoColor
        }
    }
}

# Summary
if (-not $Silent) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Auto-Fix Summary" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Fixes Applied:  $($Fixes.FixesApplied)" -ForegroundColor $(if($Fixes.FixesApplied -gt 0){$SuccessColor}else{$InfoColor})
    Write-Host "  Fixes Failed:   $($Fixes.FixesFailed)" -ForegroundColor $(if($Fixes.FixesFailed -eq 0){$SuccessColor}else{$WarningColor})
    Write-Host "  Files Modified: $($Fixes.FilesModified.Count)" -ForegroundColor $InfoColor
    
    if ($Fixes.BackupsCreated.Count -gt 0) {
        Write-Host "  Backups:        $($Fixes.BackupsCreated.Count) created" -ForegroundColor $SuccessColor
    }
    
    Write-Host ""
    
    # Re-run analyze to show improvement
    Write-Host "Verifying fixes..." -ForegroundColor $InfoColor
    $analyzeOutput2 = & flutter analyze 2>&1 | Out-String
    $errorCount2 = ($analyzeOutput2 | Select-String "error" -CaseSensitive).Count
    $warningCount2 = ($analyzeOutput2 | Select-String "warning" -CaseSensitive).Count
    
    Write-Host "  Remaining Errors:   $errorCount2" -ForegroundColor $(if($errorCount2 -eq 0){$SuccessColor}else{$WarningColor})
    Write-Host "  Remaining Warnings: $warningCount2" -ForegroundColor $(if($warningCount2 -eq 0){$SuccessColor}else{$InfoColor})
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Auto-Fix Complete                                 ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Save log
$Fixes | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\auto-fix-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

# Return fixes
return $Fixes
