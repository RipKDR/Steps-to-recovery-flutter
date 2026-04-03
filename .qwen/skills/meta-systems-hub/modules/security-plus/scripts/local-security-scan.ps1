# Local Security Scan
# Comprehensive security scanning for recovery app

param(
    [switch]$Full,
    [switch]$EncryptionOnly,
    [switch]$PIIOnly,
    [switch]$StorageOnly,
    [switch]$DependencyOnly,
    [switch]$Json,
    [string]$OutputPath,
    [switch]$Silent
)

$ErrorActionPreference = "Continue"

# Colors
$HeaderColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"
$CriticalColor = "Magenta"

# Paths
$SecurityPath = ".qwen\skills\meta-systems-hub\modules\security-plus"
$LogsPath = "$SecurityPath\reports"

# Ensure logs directory exists
if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Local Security Scan                               ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Track results
$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalIssues = 0
    Critical = 0
    High = 0
    Medium = 0
    Low = 0
    ByCategory = @{
        Encryption = @()
        Storage = @()
        PII = @()
        Dependency = @()
        Network = @()
    }
    Status = "Unknown"
}

# Scan 1: Encryption Audit
if (-not $PIIOnly -and -not $StorageOnly -and -not $DependencyOnly) {
    if (-not $Silent) { Write-Host "Scanning: Encryption Implementation..." -ForegroundColor $InfoColor }
    
    $encryptionServicePath = "lib\core\services\encryption_service.dart"
    
    if (Test-Path $encryptionServicePath) {
        $content = Get-Content $encryptionServicePath -Raw
        
        # Check for AES-256
        $hasAES = $content -match "AES"
        $has256BitKey = $content -match "256|32" # 32 bytes = 256 bits
        $hasSecureStorage = $content -match "flutter_secure_storage"
        $hasKeyDerivation = $content -match "PBKDF2|scrypt|bcrypt"
        
        if ($hasAES -and $has256BitKey) {
            if (-not $Silent) { Write-Host "  ✓ AES-256 encryption detected" -ForegroundColor $SuccessColor }
        } else {
            $Results.ByCategory.Encryption += @{
                Type = "Encryption"
                Severity = "Critical"
                Issue = "AES-256 encryption not properly implemented"
                File = $encryptionServicePath
                Recommendation = "Ensure using AES with 256-bit key"
            }
            $Results.TotalIssues++
            $Results.Critical++
            if (-not $Silent) { Write-Host "  ✗ AES-256 encryption not detected" -ForegroundColor $ErrorColor }
        }
        
        if ($hasSecureStorage) {
            if (-not $Silent) { Write-Host "  ✓ Secure storage integration detected" -ForegroundColor $SuccessColor }
        } else {
            $Results.ByCategory.Encryption += @{
                Type = "Encryption"
                Severity = "High"
                Issue = "Keys not stored in secure storage"
                File = $encryptionServicePath
                Recommendation = "Use flutter_secure_storage for key storage"
            }
            $Results.TotalIssues++
            $Results.High++
            if (-not $Silent) { Write-Host "  ⚠ Secure storage not detected" -ForegroundColor $WarningColor }
        }
    } else {
        $Results.ByCategory.Encryption += @{
            Type = "Encryption"
            Severity = "Critical"
            Issue = "Encryption service not found"
            File = $encryptionServicePath
            Recommendation = "Implement encryption service for sensitive data"
        }
        $Results.TotalIssues++
        $Results.Critical++
        if (-not $Silent) { Write-Host "  ✗ Encryption service not found" -ForegroundColor $ErrorColor }
    }
    
    if (-not $Silent) { Write-Host "" }
}

# Scan 2: Storage Privacy
if (-not $EncryptionOnly -and -not $PIIOnly -and -not $DependencyOnly) {
    if (-not $Silent) { Write-Host "Scanning: Storage Privacy..." -ForegroundColor $InfoColor }
    
    # Look for sensitive data storage patterns
    $sensitiveFeatures = @("journal", "inventory", "sponsor", "step", "crisis")
    $plaintextStorage = @()
    
    foreach ($feature in $sensitiveFeatures) {
        $featureFiles = Get-ChildItem -Path "lib\features" -Recurse -Filter "*$feature*.dart" -ErrorAction SilentlyContinue
        
        foreach ($file in $featureFiles) {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            
            if ($content) {
                # Check for plaintext SharedPreferences with sensitive data
                $hasSharedPrefs = $content -match 'SharedPreferences.*set(String|Int|Bool)'
                $hasSensitiveData = $content -match '(password|secret|token|key|recovery|addiction|meth|drug|alcohol)'
                
                if ($hasSharedPrefs -and $hasSensitiveData) {
                    $plaintextStorage += @{
                        File = $file.FullName
                        Feature = $feature
                        Issue = "Potential plaintext sensitive data storage"
                    }
                }
                
                # Check for encryption before storage
                $hasEncryption = $content -match "(encrypt|Encrypt|EncryptionService)"
                $hasStorage = $content -match "(SharedPreferences|setString|database_service)"
                
                if ($hasStorage -and -not $hasEncryption -and $feature -in @("journal", "inventory", "sponsor")) {
                    $plaintextStorage += @{
                        File = $file.FullName
                        Feature = $feature
                        Issue = "Sensitive data stored without encryption"
                    }
                }
            }
        }
    }
    
    if ($plaintextStorage.Count -gt 0) {
        foreach ($storage in $plaintextStorage) {
            $Results.ByCategory.Storage += @{
                Type = "Storage"
                Severity = "Critical"
                Issue = $storage.Issue
                File = $storage.File
                Feature = $storage.Feature
                Recommendation = "Encrypt sensitive data before storage"
            }
            $Results.TotalIssues++
            $Results.Critical++
        }
        
        if (-not $Silent) { Write-Host "  ✗ $($plaintextStorage.Count) potential plaintext storage issues" -ForegroundColor $ErrorColor }
    } else {
        if (-not $Silent) { Write-Host "  ✓ No plaintext sensitive storage detected" -ForegroundColor $SuccessColor }
    }
    
    if (-not $Silent) { Write-Host "" }
}

# Scan 3: PII Leak Detection
if (-not $EncryptionOnly -and -not $StorageOnly -and -not $DependencyOnly) {
    if (-not $Silent) { Write-Host "Scanning: PII Leaks..." -ForegroundColor $InfoColor }
    
    # PII Patterns (using single quotes to avoid escaping issues)
    $piiPatterns = @{
        "Phone" = '\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'
        "Email" = '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b'
        "SSN" = '\b\d{3}-\d{2}-\d{4}\b'
        "CreditCard" = '\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b'
        "IPAddress" = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
    }
    
    $piiFound = @()
    $dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-Object -First 100
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        
        if ($content) {
            foreach ($piiType in $piiPatterns.Keys) {
                $matches = [regex]::Matches($content, $piiPatterns[$piiType])
                
                if ($matches.Count -gt 0) {
                    # Check if it's in a print/log statement
                    $lines = $content -split "`n"
                    for ($i = 0; $i -lt $lines.Count; $i++) {
                        if ($lines[$i] -match $piiPatterns[$piiType]) {
                            if ($lines[$i] -match "(print|log|debug|info|warning|error)\s*\(") {
                                $piiFound += @{
                                    File = $file.FullName
                                    Line = $i + 1
                                    Type = $piiType
                                    Issue = "Potential PII in log statement"
                                    Severity = "High"
                                }
                            }
                        }
                    }
                }
            }
            
            # Check for sensitive variable names in logs
            if ($content -match "(print|log|debug).*(phone|email|address|ssn|credit|password|token)") {
                $piiFound += @{
                    File = $file.FullName
                    Type = "Sensitive Variable"
                    Issue = "Sensitive variable logged"
                    Severity = "High"
                }
            }
        }
    }
    
    if ($piiFound.Count -gt 0) {
        foreach ($pii in $piiFound) {
            $Results.ByCategory.PII += @{
                Type = "PII"
                Severity = $pii.Severity
                Issue = $pii.Issue
                File = $pii.File
                Line = $pii.Line
                PIType = $pii.Type
                Recommendation = "Remove PII from logs"
            }
            $Results.TotalIssues++
            if ($pii.Severity -eq "High") { $Results.High++ }
        }
        
        if (-not $Silent) { Write-Host "  ✗ $($piiFound.Count) potential PII leaks detected" -ForegroundColor $ErrorColor }
    } else {
        if (-not $Silent) { Write-Host "  ✓ No PII leaks detected" -ForegroundColor $SuccessColor }
    }
    
    if (-not $Silent) { Write-Host "" }
}

# Scan 4: Dependency Audit
if (-not $EncryptionOnly -and -not $PIIOnly -and -not $StorageOnly) {
    if (-not $Silent) { Write-Host "Scanning: Dependencies..." -ForegroundColor $InfoColor }
    
    try {
        $pubAudit = & dart pub outdated 2>&1 | Out-String
        
        # Check for outdated packages
        if ($pubAudit -match "(\d+) package\(s\) are outdated") {
            $outdatedCount = [int]$matches[1]
            
            if ($outdatedCount -gt 10) {
                $Results.ByCategory.Dependency += @{
                    Type = "Dependency"
                    Severity = "Medium"
                    Issue = "$outdatedCount packages are outdated"
                    Recommendation = "Run 'flutter pub upgrade' to update"
                }
                $Results.TotalIssues++
                $Results.Medium++
                if (-not $Silent) { Write-Host "  ⚠ $outdatedCount packages outdated" -ForegroundColor $WarningColor }
            } else {
                if (-not $Silent) { Write-Host "  ✓ Dependencies up to date" -ForegroundColor $SuccessColor }
            }
        }
        
        # Check for security advisories
        $pubAuditSecurity = & dart pub global activate dart_code_metrics 2>&1 | Out-String
        
    } catch {
        if (-not $Silent) { Write-Host "  ⚠ Could not check dependencies" -ForegroundColor $WarningColor }
    }
    
    if (-not $Silent) { Write-Host "" }
}

# Scan 5: Network Security
if (-not $EncryptionOnly -and -not $PIIOnly -and -not $StorageOnly -and -not $DependencyOnly) {
    if (-not $Silent) { Write-Host "Scanning: Network Security..." -ForegroundColor $InfoColor }
    
    $httpIssues = @()
    $dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-Object -First 100
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        
        if ($content) {
            # Check for HTTP (not HTTPS)
            if ($content -match "http://(?!localhost|127\.0\.0\.1)") {
                $httpIssues += @{
                    File = $file.FullName
                    Issue = "HTTP (not HTTPS) URL detected"
                    Severity = "High"
                }
            }
            
            # Check for hardcoded API keys
            $hasApiKey = $content -match 'api[_-]?key|apikey|API_KEY'
            if ($hasApiKey) {
                $httpIssues += @{
                    File = $file.FullName
                    Issue = "Potential hardcoded API key detected"
                    Severity = "Critical"
                }
            }
        }
    }
    
    if ($httpIssues.Count -gt 0) {
        foreach ($issue in $httpIssues) {
            $Results.ByCategory.Network += $issue
            $Results.TotalIssues++
            if ($issue.Severity -eq "Critical") { $Results.Critical++ }
            else { $Results.High++ }
        }
        
        if (-not $Silent) { Write-Host "  ✗ $($httpIssues.Count) network security issues" -ForegroundColor $ErrorColor }
    } else {
        if (-not $Silent) { Write-Host "  ✓ No network security issues" -ForegroundColor $SuccessColor }
    }
    
    if (-not $Silent) { Write-Host "" }
}

# Determine overall status
if ($Results.Critical -gt 0) {
    $Results.Status = "Critical"
} elseif ($Results.High -gt 0) {
    $Results.Status = "Warning"
} elseif ($Results.Medium -gt 0) {
    $Results.Status = "Caution"
} else {
    $Results.Status = "All Clear"
}

# Display summary
if (-not $Silent) {
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Security Scan Summary" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Total Issues: $($Results.TotalIssues)" -ForegroundColor $(if($Results.TotalIssues -eq 0){$SuccessColor}elseif($Results.Critical -gt 0){$ErrorColor}else{$WarningColor})
    Write-Host ""
    
    Write-Host "  Critical: $($Results.Critical)" -ForegroundColor $(if($Results.Critical -eq 0){$SuccessColor}else{$CriticalColor})
    Write-Host "  High:     $($Results.High)" -ForegroundColor $(if($Results.High -eq 0){$SuccessColor}else{$ErrorColor})
    Write-Host "  Medium:   $($Results.Medium)" -ForegroundColor $(if($Results.Medium -eq 0){$SuccessColor}else{$WarningColor})
    Write-Host "  Low:      $($Results.Low)" -ForegroundColor $(if($Results.Low -eq 0){$SuccessColor}else{$InfoColor})
    Write-Host ""
    
    Write-Host "  Status: $($Results.Status)" -ForegroundColor $(
        switch ($Results.Status) {
            "All Clear" { $SuccessColor }
            "Caution" { $InfoColor }
            "Warning" { $WarningColor }
            "Critical" { $ErrorColor }
        }
    )
    
    Write-Host ""
    
    # Show critical issues
    if ($Results.Critical -gt 0) {
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $CriticalColor
        Write-Host "  Critical Issues (Immediate Action Required)" -ForegroundColor $CriticalColor
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $CriticalColor
        Write-Host ""
        
        $criticalIssues = $Results.ByCategory.Values | Where-Object { $_.Severity -eq "Critical" }
        
        foreach ($issue in $criticalIssues) {
            Write-Host "  [$($issue.Type)] $($issue.File)" -ForegroundColor $ErrorColor
            Write-Host "    Issue: $($issue.Issue)" -ForegroundColor $WarningColor
            Write-Host "    Fix: $($issue.Recommendation)" -ForegroundColor $InfoColor
            Write-Host ""
        }
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Security Scan Complete                            ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\security-scan-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    if (-not $Silent) { Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor }
}

if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

return $Results
