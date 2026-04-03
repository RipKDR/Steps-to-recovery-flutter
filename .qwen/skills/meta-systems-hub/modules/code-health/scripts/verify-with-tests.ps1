# Verify Fixes with Tests
# Runs relevant tests after auto-fix to ensure no regressions

param(
    [switch]$Full,
    [switch]$Json,
    [string]$OutputPath,
    [string[]]$ModifiedFiles,
    [switch]$Silent
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

if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Test Verification                                 ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Track results
$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    SkippedTests = 0
    TestFiles = @()
    ModifiedFiles = $ModifiedFiles
    RelevantTests = @()
    Status = "Unknown"
}

# Find relevant tests for modified files
if ($ModifiedFiles -and $ModifiedFiles.Count -gt 0) {
    if (-not $Silent) { Write-Host "Finding relevant tests for modified files..." -ForegroundColor $InfoColor }
    
    foreach ($file in $ModifiedFiles) {
        # Extract feature/screen/service name from path
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $featureName = ($file -split "[\\/]features[\\/]")[1] -split "[\\/]")[0]
        
        # Look for matching test files
        $testPatterns = @(
            "test/**/*${fileName}*test.dart",
            "test/**/*${featureName}*test.dart",
            "test/**/*_test.dart"
        )
        
        foreach ($pattern in $testPatterns) {
            $testFiles = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
            
            foreach ($testFile in $testFiles) {
                if ($Results.TestFiles -notcontains $testFile.FullName) {
                    $Results.TestFiles += $testFile.FullName
                    $Results.RelevantTests += @{
                        TestFile = $testFile.FullName
                        RelatedTo = $file
                        Feature = $featureName
                    }
                }
            }
        }
    }
    
    if (-not $Silent) { Write-Host "  Found $($Results.TestFiles.Count) relevant test files" -ForegroundColor $InfoColor }
} else {
    # Run all tests
    if (-not $Silent) { Write-Host "No modified files specified - will run all tests" -ForegroundColor $InfoColor }
}

# Run tests
if (-not $Silent) { Write-Host "" }
Write-Host "Running tests..." -ForegroundColor $InfoColor

$testOutput = & flutter test 2>&1 | Out-String
$testExitCode = $LASTEXITCODE

# Parse test output
$lines = $testOutput -split "`n"

foreach ($line in $lines) {
    if ($line -match "All tests passed!") {
        $Results.Status = "Pass"
        break
    } elseif ($line -match "Failed tests:") {
        $Results.Status = "Fail"
    } elseif ($line -match "(\d+) tests? passed") {
        $Results.PassedTests = [int]$matches[1]
    } elseif ($line -match "(\d+) tests? failed") {
        $Results.FailedTests = [int]$matches[1]
    } elseif ($line -match "(\d+) tests? skipped") {
        $Results.SkippedTests = [int]$matches[1]
    }
}

$Results.TotalTests = $Results.PassedTests + $Results.FailedTests + $Results.SkippedTests

# Display results
if (-not $Silent) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Test Verification Results" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Total Tests:  $($Results.TotalTests)" -ForegroundColor $InfoColor
    Write-Host "  Passed:       $($Results.PassedTests)" -ForegroundColor $(if($Results.FailedTests -eq 0){$SuccessColor}else{$WarningColor})
    Write-Host "  Failed:       $($Results.FailedTests)" -ForegroundColor $(if($Results.FailedTests -eq 0){$SuccessColor}else{$ErrorColor})
    Write-Host "  Skipped:      $($Results.SkippedTests)" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "  Status: $($Results.Status)" -ForegroundColor $(if($Results.Status -eq "Pass"){$SuccessColor}else{$ErrorColor})
    Write-Host ""
    
    # Show relevant tests
    if ($Results.RelevantTests.Count -gt 0) {
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
        Write-Host "  Relevant Tests for Modified Files" -ForegroundColor $HeaderColor
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
        Write-Host ""
        
        $Results.RelevantTests | Select-Object -First 10 | ForEach-Object {
            Write-Host "  Test: $($_.TestFile)" -ForegroundColor $InfoColor
            Write-Host "  Related to: $($_.RelatedTo)" -ForegroundColor $InfoColor
            Write-Host ""
        }
    }
    
    # Show test output if failures
    if ($Results.FailedTests -gt 0) {
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host "  Failed Tests" -ForegroundColor $ErrorColor
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host ""
        
        $testOutput | Select-String "FAILED" | Select-Object -First 10 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor $ErrorColor
        }
        
        Write-Host ""
        Write-Host "  ⚠ Test failures detected - consider rolling back changes" -ForegroundColor $WarningColor
        Write-Host ""
    }
    
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Test Verification Complete                        ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\test-verification-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    if (-not $Silent) { Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor }
}

if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

# Return exit code based on results
if ($Results.Status -eq "Pass") {
    return $Results
} else {
    return $Results
}
