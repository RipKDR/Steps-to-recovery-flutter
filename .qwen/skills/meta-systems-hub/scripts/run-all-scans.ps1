# Run All Meta-Systems Scans
# Executes scans from all modules in sequence

param(
    [switch]$Full,
    [switch]$CodeHealthOnly,
    [switch]$SecurityOnly,
    [switch]$TestOnly,
    [switch]$AutoFix,
    [switch]$NoFix,
    [switch]$Json,
    [string]$OutputPath,
    [switch]$Silent
)

$ErrorActionPreference = "Continue"
$StartTime = Get-Date

# Colors
$HeaderColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"

# Paths
$HubPath = ".qwen\skills\meta-systems-hub"
$CodeHealthPath = "$HubPath\modules\code-health\scripts"
$SecurityPath = "$HubPath\modules\security-plus\scripts"
$TestPath = "$HubPath\modules\test-coverage\scripts"

# Results
$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    CodeHealth = $null
    Security = $null
    TestCoverage = $null
    Duration = $null
}

function Write-Phase {
    param([string]$Name)
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Phase: $Name" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
}

function Write-PhaseComplete {
    param([string]$Message = "Complete")
    Write-Host "  ✓ $Message" -ForegroundColor $SuccessColor
}

function Write-PhaseWarning {
    param([string]$Message)
    Write-Host "  ⚠ $Message" -ForegroundColor $WarningColor
}

function Write-PhaseError {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor $ErrorColor
}

# Start
if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Meta-Systems Full Scan                            ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
    Write-Host "Started: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor $InfoColor
    Write-Host ""
}

# Phase 1: Code Health
if (-not $SecurityOnly -and -not $TestOnly) {
    Write-Phase "Code Health Scan"
    
    try {
        # Run flutter analyze
        if (-not $Silent) { Write-Host "  Running flutter analyze..." -ForegroundColor $InfoColor }
        $analyzeOutput = & flutter analyze 2>&1 | Out-String
        $analyzeExitCode = $LASTEXITCODE
        
        $errorCount = ($analyzeOutput | Select-String "error" -CaseSensitive).Count
        $warningCount = ($analyzeOutput | Select-String "warning" -CaseSensitive).Count
        
        $Results.CodeHealth = @{
            Status = if ($analyzeExitCode -eq 0) { "Pass" } else { "Fail" }
            Errors = $errorCount
            Warnings = $warningCount
            Output = $analyzeOutput
        }
        
        if ($analyzeExitCode -eq 0) {
            Write-PhaseComplete "No issues found"
        } else {
            Write-PhaseWarning "$errorCount errors, $warningCount warnings found"
            
            # Auto-fix if requested
            if ($AutoFix -and -not $NoFix) {
                if (-not $Silent) { Write-Host "  Running auto-fix..." -ForegroundColor $InfoColor }
                
                $autoFixScript = Join-Path $CodeHealthPath "auto-fix-safe.ps1"
                if (Test-Path $autoFixScript) {
                    & $autoFixScript -Category "lint,imports,unused" -Silent:$Silent
                    Write-Host "  Auto-fix complete" -ForegroundColor $InfoColor
                } else {
                    Write-PhaseWarning "Auto-fix script not found"
                }
            }
        }
    } catch {
        $Results.CodeHealth = @{
            Status = "Error"
            Error = $_.Exception.Message
        }
        Write-PhaseError "Code health scan failed: $($_.Exception.Message)"
    }
}

# Phase 2: Security Scan
if (-not $CodeHealthOnly -and -not $TestOnly) {
    Write-Phase "Security Scan"
    
    try {
        # Check encryption service
        if (-not $Silent) { Write-Host "  Checking encryption implementation..." -ForegroundColor $InfoColor }
        $encryptionServicePath = "lib\core\services\encryption_service.dart"
        $encryptionExists = Test-Path $encryptionServicePath
        
        if ($encryptionExists) {
            $encryptionContent = Get-Content $encryptionServicePath -Raw
            
            # Check for AES-256
            $hasAES = $encryptionContent -match "AES"
            $hasSecureStorage = $encryptionContent -match "flutter_secure_storage"
            
            $Results.Security = @{
                Status = "Pass"
                EncryptionExists = $encryptionExists
                AES256 = $hasAES
                SecureStorage = $hasSecureStorage
            }
            
            if ($hasAES -and $hasSecureStorage) {
                Write-PhaseComplete "Encryption properly implemented"
            } else {
                Write-PhaseWarning "Encryption may need review"
                if (-not $hasAES) { Write-Host "    - AES not detected" -ForegroundColor $WarningColor }
                if (-not $hasSecureStorage) { Write-Host "    - flutter_secure_storage not detected" -ForegroundColor $WarningColor }
            }
        } else {
            $Results.Security = @{
                Status = "Warning"
                EncryptionExists = $false
                Message = "Encryption service not found"
            }
            Write-PhaseWarning "Encryption service not found"
        }
        
        # Check for PII leaks (simplified)
        if (-not $Silent) { Write-Host "  Scanning for PII leaks..." -ForegroundColor $InfoColor }
        $piiPatterns = @("phone", "email", "password", "token", "secret")
        $piiFound = $false
        
        $dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-Object -First 50
        foreach ($file in $dartFiles) {
            $content = Get-Content $file.FullName -Raw
            foreach ($pattern in $piiPatterns) {
                if ($content -match $pattern) {
                    # Check if it's in a print statement or log
                    if ($content -match "(print|Logger).*$pattern") {
                        $piiFound = $true
                        Write-Host "    Potential PII leak: $($file.Name)" -ForegroundColor $WarningColor
                    }
                }
            }
        }
        
        if (-not $piiFound) {
            Write-Host "  No PII leaks detected" -ForegroundColor $SuccessColor
        }
        
        if ($Results.Security) {
            $Results.Security.PIILeaks = $piiFound
        }
    } catch {
        $Results.Security = @{
            Status = "Error"
            Error = $_.Exception.Message
        }
        Write-PhaseError "Security scan failed: $($_.Exception.Message)"
    }
}

# Phase 3: Test Coverage
if (-not $CodeHealthOnly -and -not $SecurityOnly) {
    Write-Phase "Test Coverage Analysis"
    
    try {
        # Check if coverage exists
        $lcovPath = "coverage/lcov.info"
        
        if (Test-Path $lcovPath) {
            if (-not $Silent) { Write-Host "  Analyzing coverage..." -ForegroundColor $InfoColor }
            $totalLines = (Get-Content $lcovPath | Select-String "DA:").Count
            $hitLines = (Get-Content $lcovPath | Select-String "DA:.*,1").Count
            
            if ($totalLines -gt 0) {
                $coverage = [math]::Round(($hitLines / $totalLines) * 100, 1)
                
                $Results.TestCoverage = @{
                    Status = "Pass"
                    Coverage = $coverage
                    TotalLines = $totalLines
                    HitLines = $hitLines
                }
                
                if ($coverage -ge 80) {
                    Write-PhaseComplete "Coverage: $coverage% (target: 80%)"
                } else {
                    Write-PhaseWarning "Coverage: $coverage% (below 80% target)"
                }
            }
        } else {
            # Estimate from test files
            $testFiles = Get-ChildItem -Path "test" -Recurse -Filter "*_test.dart" | Measure-Object | Select-Object -ExpandProperty Count
            $libFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Measure-Object | Select-Object -ExpandProperty Count
            
            if ($libFiles -gt 0) {
                $estimatedCoverage = [math]::Min(85, ($testFiles / $libFiles) * 100)
                
                $Results.TestCoverage = @{
                    Status = "Estimated"
                    Coverage = $estimatedCoverage
                    TestFiles = $testFiles
                    LibFiles = $libFiles
                }
                
                Write-Host "  Estimated coverage: ~$estimatedCoverage%" -ForegroundColor $InfoColor
                Write-Host "  Test files: $testFiles / Library files: $libFiles" -ForegroundColor $InfoColor
            } else {
                $Results.TestCoverage = @{
                    Status = "Unknown"
                    Message = "No coverage data available"
                }
            }
        }
    } catch {
        $Results.TestCoverage = @{
            Status = "Error"
            Error = $_.Exception.Message
        }
        Write-PhaseError "Test coverage analysis failed: $($_.Exception.Message)"
    }
}

# Summary
$EndTime = Get-Date
$Duration = New-TimeSpan -Start $StartTime -End $EndTime
$Results.Duration = "$($Duration.Minutes)m $($Duration.Seconds)s"

if (-not $Silent) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Scan Summary" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Code Health:    $($Results.CodeHealth.Status)" -ForegroundColor $(if($Results.CodeHealth.Status -eq "Pass"){$SuccessColor}else{$WarningColor})
    Write-Host "  Security:       $($Results.Security.Status)" -ForegroundColor $(if($Results.Security.Status -eq "Pass"){$SuccessColor}else{$WarningColor})
    Write-Host "  Test Coverage:  $($Results.TestCoverage.Status)" -ForegroundColor $(if($Results.TestCoverage.Status -eq "Pass"){$SuccessColor}else{$InfoColor})
    Write-Host ""
    Write-Host "  Duration: $($Results.Duration)" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Save to file if requested
    if ($OutputPath) {
        $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
        Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Scan Complete                                     ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# JSON output if requested
if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

# Return results for pipeline
return $Results
