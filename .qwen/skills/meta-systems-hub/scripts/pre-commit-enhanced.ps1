# Pre-Commit Enhanced Check
# Runs comprehensive checks before allowing commit
# Designed to be used as a git pre-commit hook

param(
    [switch]$NoFix,
    [switch]$Verbose,
    [switch]$Bypass
)

$ErrorActionPreference = "Stop"

# Colors
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Pre-Commit Enhanced Check                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Bypass for emergencies
if ($Bypass) {
    Write-Host "  ⚠ BYPASS MODE - Skipping checks" -ForegroundColor $WarningColor
    Write-Host ""
    exit 0
}

# Configuration
$AllowCommitWithWarnings = $true
$BlockCommitOnErrors = $true

# Track results
$HasErrors = $false
$HasWarnings = $false
$ChecksPassed = 0
$ChecksFailed = 0

# Check 1: Flutter Analyze
Write-Host "Check 1: Flutter Analyze" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

try {
    $analyzeOutput = & flutter analyze 2>&1 | Out-String
    $errorCount = ($analyzeOutput | Select-String "error" -CaseSensitive).Count
    $warningCount = ($analyzeOutput | Select-String "warning" -CaseSensitive).Count
    
    if ($errorCount -gt 0) {
        Write-Host "  ✗ $errorCount errors found" -ForegroundColor $ErrorColor
        $HasErrors = $true
        $ChecksFailed++
        
        if ($Verbose) {
            Write-Host $analyzeOutput -ForegroundColor $ErrorColor
        }
    } else {
        Write-Host "  ✓ No errors" -ForegroundColor $SuccessColor
        $ChecksPassed++
        
        if ($warningCount -gt 0) {
            Write-Host "  ⚠ $warningCount warnings (non-blocking)" -ForegroundColor $WarningColor
            $HasWarnings = $true
        }
    }
} catch {
    Write-Host "  ✗ Flutter analyze failed: $($_.Exception.Message)" -ForegroundColor $ErrorColor
    $HasErrors = $true
    $ChecksFailed++
}

Write-Host ""

# Check 2: Git Stash (backup before any potential fixes)
Write-Host "Check 2: Creating Backup" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

try {
    $stashName = "pre-commit-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    & git stash push -m $stashName 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Backup created: $stashName" -ForegroundColor $SuccessColor
        $ChecksPassed++
    } else {
        Write-Host "  ⚠ Could not create backup (continuing anyway)" -ForegroundColor $WarningColor
    }
} catch {
    Write-Host "  ⚠ Git stash not available" -ForegroundColor $WarningColor
}

Write-Host ""

# Check 3: Auto-Fix Safe Issues (if enabled)
if (-not $NoFix -and -not $HasErrors) {
    Write-Host "Check 3: Auto-Fix Safe Issues" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
    
    $autoFixScript = ".qwen\skills\meta-systems-hub\modules\code-health\scripts\auto-fix-safe.ps1"
    
    if (Test-Path $autoFixScript) {
        try {
            Write-Host "  Running auto-fix..." -ForegroundColor $InfoColor
            & $autoFixScript -Category "lint,imports,unused" -Silent -ErrorAction SilentlyContinue
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Auto-fix complete" -ForegroundColor $SuccessColor
                $ChecksPassed++
                
                # Re-run analyze to verify fixes
                $analyzeOutput2 = & flutter analyze 2>&1 | Out-String
                $errorCount2 = ($analyzeOutput2 | Select-String "error" -CaseSensitive).Count
                
                if ($errorCount2 -lt $errorCount) {
                    Write-Host "  ✓ Fixed $($errorCount - $errorCount2) issues" -ForegroundColor $SuccessColor
                }
            } else {
                Write-Host "  ⚠ Auto-fix completed with warnings" -ForegroundColor $WarningColor
                $HasWarnings = $true
            }
        } catch {
            Write-Host "  ⚠ Auto-fix failed: $($_.Exception.Message)" -ForegroundColor $WarningColor
            $HasWarnings = $true
        }
    } else {
        Write-Host "  ℹ Auto-fix script not found (skipping)" -ForegroundColor $InfoColor
    }
    
    Write-Host ""
}

# Check 4: Test Compilation
Write-Host "Check 4: Test Compilation" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

try {
    Write-Host "  Compiling tests..." -ForegroundColor $InfoColor
    $testCompileOutput = & flutter test --no-run 2>&1 | Out-String
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Tests compile successfully" -ForegroundColor $SuccessColor
        $ChecksPassed++
    } else {
        Write-Host "  ✗ Test compilation failed" -ForegroundColor $ErrorColor
        $HasErrors = $true
        $ChecksFailed++
        
        if ($Verbose) {
            Write-Host $testCompileOutput -ForegroundColor $ErrorColor
        }
    }
} catch {
    Write-Host "  ✗ Test compilation failed: $($_.Exception.Message)" -ForegroundColor $ErrorColor
    $HasErrors = $true
    $ChecksFailed++
}

Write-Host ""

# Check 5: Security Quick Scan
Write-Host "Check 5: Security Quick Scan" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$encryptionExists = Test-Path "lib\core\services\encryption_service.dart"
if ($encryptionExists) {
    Write-Host "  ✓ Encryption service exists" -ForegroundColor $SuccessColor
    $ChecksPassed++
} else {
    Write-Host "  ⚠ Encryption service not found" -ForegroundColor $WarningColor
    $HasWarnings = $true
}

Write-Host ""

# Summary
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Pre-Commit Check Summary" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Checks Passed:  $ChecksPassed" -ForegroundColor $SuccessColor
Write-Host "  Checks Failed:  $ChecksFailed" -ForegroundColor $(if($ChecksFailed -eq 0){$SuccessColor}else{$ErrorColor})
Write-Host ""

# Decision
if ($HasErrors -and $BlockCommitOnErrors) {
    Write-Host "  ✗ COMMIT BLOCKED - Fix errors before committing" -ForegroundColor $ErrorColor
    Write-Host ""
    Write-Host "  To bypass (not recommended):" -ForegroundColor $InfoColor
    Write-Host "  git commit --no-verify" -ForegroundColor $InfoColor
    Write-Host ""
    Write-Host "  Or use: .\.qwen\skills\meta-systems-hub\scripts\pre-commit-enhanced.ps1 -Bypass" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Restore from backup if we stashed
    try {
        & git stash pop 2>&1 | Out-Null
        Write-Host "  Changes restored from backup" -ForegroundColor $InfoColor
    } catch {
        # Ignore restore errors
    }
    
    exit 1
} elseif ($HasWarnings -and -not $AllowCommitWithWarnings) {
    Write-Host "  ⚠ COMMIT BLOCKED - Fix warnings before committing" -ForegroundColor $WarningColor
    Write-Host ""
    exit 1
} else {
    if ($HasWarnings) {
        Write-Host "  ⚠ Commit allowed with warnings" -ForegroundColor $WarningColor
    } else {
        Write-Host "  ✓ All checks passed - Commit allowed" -ForegroundColor $SuccessColor
    }
    Write-Host ""
    exit 0
}
