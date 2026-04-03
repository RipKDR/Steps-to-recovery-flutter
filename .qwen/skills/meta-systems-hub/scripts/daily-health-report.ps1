# Daily Health Report
# Generates comprehensive daily report for all meta-systems

param(
    [switch]$SaveToFile,
    [string]$OutputPath = ".qwen\skills\meta-systems-hub\reports\daily-report.json",
    [switch]$SendToSelfEvolving
)

$ErrorActionPreference = "Continue"
$Date = Get-Date -Format "yyyy-MM-dd"
$Time = Get-Date -Format "HH:mm:ss"

# Colors
$HeaderColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"

# Paths
$HubPath = ".qwen\skills\meta-systems-hub"
$LogsPath = "$HubPath\logs"

# Ensure logs directory exists
if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║         Daily Health Report - $Date                      ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# Collect metrics
$Report = @{
    Date = $Date
    Time = $Time
    CodeHealth = @{}
    Security = @{}
    TestCoverage = @{}
    Recommendations = @()
}

# Code Health Metrics
Write-Host "Code Health" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

try {
    $analyzeOutput = & flutter analyze 2>&1 | Out-String
    $errorCount = ($analyzeOutput | Select-String "error" -CaseSensitive).Count
    $warningCount = ($analyzeOutput | Select-String "warning" -CaseSensitive).Count
    
    $Report.CodeHealth = @{
        Errors = $errorCount
        Warnings = $warningCount
        Status = if ($errorCount -eq 0 -and $warningCount -eq 0) { "Excellent" } elseif ($errorCount -eq 0) { "Good" } else { "Needs Work" }
    }
    
    Write-Host "  Errors:   $errorCount" -ForegroundColor $(if($errorCount -eq 0){$SuccessColor}else{$ErrorColor})
    Write-Host "  Warnings: $warningCount" -ForegroundColor $(if($warningCount -eq 0){$SuccessColor}else{$WarningColor})
    Write-Host "  Status:   $($Report.CodeHealth.Status)" -ForegroundColor $(if($Report.CodeHealth.Status -eq "Excellent"){$SuccessColor}else{$WarningColor})
} catch {
    Write-Host "  Error analyzing code: $($_.Exception.Message)" -ForegroundColor $ErrorColor
    $Report.CodeHealth = @{ Status = "Error"; Error = $_.Exception.Message }
}

Write-Host ""

# Security Metrics
Write-Host "Security" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$encryptionExists = Test-Path "lib\core\services\encryption_service.dart"
$secureStorageInPubspec = (Get-Content "pubspec.yaml" -Raw) -match "flutter_secure_storage"

$Report.Security = @{
    EncryptionServiceExists = $encryptionExists
    SecureStorageConfigured = $secureStorageInPubspec
    Status = if ($encryptionExists -and $secureStorageInPubspec) { "All Clear" } else { "Review Needed" }
}

Write-Host "  Encryption Service: $(if($encryptionExists){"✓ Exists"}else{"✗ Missing"})" -ForegroundColor $(if($encryptionExists){$SuccessColor}else{$ErrorColor})
Write-Host "  Secure Storage:     $(if($secureStorageInPubspec){"✓ Configured"}else{"✗ Not Configured"})" -ForegroundColor $(if($secureStorageInPubspec){$SuccessColor}else{$WarningColor})
Write-Host "  Status: $($Report.Security.Status)" -ForegroundColor $(if($Report.Security.Status -eq "All Clear"){$SuccessColor}else{$WarningColor})

Write-Host ""

# Test Coverage Metrics
Write-Host "Test Coverage" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$testFiles = Get-ChildItem -Path "test" -Recurse -Filter "*_test.dart" | Measure-Object | Select-Object -ExpandProperty Count
$libFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Measure-Object | Select-Object -ExpandProperty Count

if ($libFiles -gt 0) {
    $testRatio = [math]::Round(($testFiles / $libFiles) * 100, 1)
} else {
    $testRatio = 0
}

$Report.TestCoverage = @{
    TestFiles = $testFiles
    LibraryFiles = $libFiles
    TestRatio = $testRatio
    Status = if ($testRatio -ge 80) { "Excellent" } elseif ($testRatio -ge 50) { "Good" } else { "Needs Work" }
}

Write-Host "  Test Files:     $testFiles" -ForegroundColor $InfoColor
Write-Host "  Library Files:  $libFiles" -ForegroundColor $InfoColor
Write-Host "  Test Ratio:     $testRatio%" -ForegroundColor $(if($testRatio -ge 80){$SuccessColor}elseif($testRatio -ge 50){$WarningColor}else{$ErrorColor})
Write-Host "  Status:         $($Report.TestCoverage.Status)" -ForegroundColor $(if($Report.TestCoverage.Status -eq "Excellent"){$SuccessColor}else{$WarningColor})

Write-Host ""

# Recommendations
Write-Host "Recommendations" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$Recommendations = @()

if ($Report.CodeHealth.Errors -gt 0) {
    $rec = "Fix $($Report.CodeHealth.Errors) errors in codebase"
    Write-Host "  ⚠ $rec" -ForegroundColor $WarningColor
    $Recommendations += $rec
}

if ($Report.CodeHealth.Warnings -gt 5) {
    $rec = "Review $($Report.CodeHealth.Warnings) warnings"
    Write-Host "  ⚠ $rec" -ForegroundColor $WarningColor
    $Recommendations += $rec
}

if (-not $encryptionExists) {
    $rec = "Implement encryption service for sensitive data"
    Write-Host "  ⚠ $rec" -ForegroundColor $WarningColor
    $Recommendations += $rec
}

if ($testRatio -lt 80) {
    $rec = "Increase test coverage (current: $testRatio%, target: 80%)"
    Write-Host "  ⚠ $rec" -ForegroundColor $WarningColor
    $Recommendations += $rec
}

if ($Recommendations.Count -eq 0) {
    Write-Host "  ✓ All systems operational - no critical recommendations" -ForegroundColor $SuccessColor
}

$Report.Recommendations = $Recommendations

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $InfoColor
Write-Host ""

# Save to file
if ($SaveToFile) {
    $Report | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "Report saved to: $OutputPath" -ForegroundColor $InfoColor
}

# Send to self-evolving-agent
if ($SendToSelfEvolving) {
    $SelfEvolvingPath = ".qwen\skills\self-evolving-agent\knowledge"
    if (Test-Path $SelfEvolvingPath) {
        $learningFile = "$SelfEvolvingPath\daily-report-$Date.json"
        $Report | ConvertTo-Json -Depth 5 | Out-File -FilePath $learningFile -Encoding utf8
        Write-Host "Learning synced to self-evolving-agent: $learningFile" -ForegroundColor $InfoColor
    }
}

# Log to history
$LogFile = "$LogsPath\daily-reports.log"
$LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Code: $($Report.CodeHealth.Status), Security: $($Report.Security.Status), Tests: $($Report.TestCoverage.Status)"
Add-Content -Path $LogFile -Value $LogEntry

Write-Host "Next report: Tomorrow at 6:00 AM" -ForegroundColor $InfoColor
Write-Host ""

return $Report
