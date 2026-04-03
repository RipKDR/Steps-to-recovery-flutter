# Encryption Audit
# Validates AES-256 encryption implementation for recovery app

param(
    [switch]$Full,
    [switch]$Json,
    [string]$OutputPath,
    [switch]$Silent,
    [switch]$FixSuggestions
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
    Write-Host "║         Encryption Audit                                  ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Track results
$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Status = "Unknown"
    Score = 0
    MaxScore = 100
    Checks = @()
    CriticalIssues = 0
    HighIssues = 0
    Recommendations = @()
}

$Score = 0
$MaxScore = 100

# Check 1: Encryption Service Exists
Write-Host "Check 1: Encryption Service" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$encryptionServicePath = "lib\core\services\encryption_service.dart"

if (Test-Path $encryptionServicePath) {
    Write-Host "  ✓ Encryption service exists" -ForegroundColor $SuccessColor
    $Score += 10
    
    $Results.Checks += @{
        Name = "Encryption Service Exists"
        Passed = $true
        Score = 10
    }
} else {
    Write-Host "  ✗ Encryption service not found" -ForegroundColor $ErrorColor
    Write-Host "    Expected: $encryptionServicePath" -ForegroundColor $InfoColor
    Write-Host "    Recommendation: Create encryption service for sensitive data" -ForegroundColor $WarningColor
    
    $Results.CriticalIssues++
    $Results.Recommendations += "Implement encryption service at $encryptionServicePath"
    
    $Results.Checks += @{
        Name = "Encryption Service Exists"
        Passed = $false
        Score = 0
        Critical = $true
    }
}

Write-Host ""

# Check 2: AES-256 Implementation
if (Test-Path $encryptionServicePath) {
    Write-Host "Check 2: AES-256 Implementation" -ForegroundColor $HeaderColor
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
    
    $content = Get-Content $encryptionServicePath -Raw
    
    # Check for AES
    $hasAES = $content -match "AES"
    if ($hasAES) {
        Write-Host "  ✓ AES algorithm detected" -ForegroundColor $SuccessColor
        $Score += 10
    } else {
        Write-Host "  ✗ AES algorithm not detected" -ForegroundColor $ErrorColor
        $Results.CriticalIssues++
        $Results.Recommendations += "Use AES encryption algorithm"
    }
    
    # Check for 256-bit key
    $has256BitKey = $content -match "(256|32[^0-9])" # 32 bytes = 256 bits
    if ($has256BitKey) {
        Write-Host "  ✓ 256-bit key size detected" -ForegroundColor $SuccessColor
        $Score += 10
    } else {
        Write-Host "  ⚠ 256-bit key size not explicitly detected" -ForegroundColor $WarningColor
        $Results.HighIssues++
        $Results.Recommendations += "Ensure using 256-bit (32 byte) keys"
    }
    
    # Check for secure random IV
    $hasSecureIV = $content -match "(IV|iv|initializationVector).*=(.*)(random|Random)"
    if ($hasSecureIV) {
        Write-Host "  ✓ Secure IV generation detected" -ForegroundColor $SuccessColor
        $Score += 5
    } else {
        Write-Host "  ⚠ Secure IV generation not detected" -ForegroundColor $WarningColor
        $Results.HighIssues++
        $Results.Recommendations += "Use secure random IV for each encryption"
    }
    
    # Check for CBC or GCM mode
    $hasSecureMode = $content -match "(CBC|GCM|CTR)"
    if ($hasSecureMode) {
        Write-Host "  ✓ Secure block mode detected" -ForegroundColor $SuccessColor
        $Score += 5
    } else {
        Write-Host "  ⚠ Block mode not explicitly detected" -ForegroundColor $WarningColor
        $Results.Recommendations += "Use CBC or GCM mode"
    }
    
    $Results.Checks += @{
        Name = "AES-256 Implementation"
        Passed = ($hasAES -and $has256BitKey)
        Score = $(if($hasAES){10}else{0}) + $(if($has256BitKey){10}else{0}) + $(if($hasSecureIV){5}else{0}) + $(if($hasSecureMode){5}else{0})
    }
    
    Write-Host ""
    
    # Check 3: Key Storage
    Write-Host "Check 3: Key Storage Security" -ForegroundColor $HeaderColor
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
    
    # Check for flutter_secure_storage
    $hasSecureStorage = $content -match "flutter_secure_storage"
    if ($hasSecureStorage) {
        Write-Host "  ✓ Secure storage integration detected" -ForegroundColor $SuccessColor
        $Score += 15
        
        # Check for Android options
        $hasAndroidOptions = $content -match "AndroidOptions"
        if ($hasAndroidOptions) {
            Write-Host "  ✓ Android security options configured" -ForegroundColor $SuccessColor
            $Score += 5
        }
        
        # Check for iOS options
        $hasIOSOptions = $content -match "IOSOptions"
        if ($hasIOSOptions) {
            Write-Host "  ✓ iOS security options configured" -ForegroundColor $SuccessColor
            $Score += 5
        }
    } else {
        Write-Host "  ✗ Keys may not be stored securely" -ForegroundColor $ErrorColor
        Write-Host "    Recommendation: Use flutter_secure_storage for key storage" -ForegroundColor $WarningColor
        $Results.CriticalIssues++
        $Results.Recommendations += "Store encryption keys in flutter_secure_storage (Keychain/Keystore)"
    }
    
    # Check for hardcoded keys
    $hasHardcodedKey = $content -match "(key|secret)\s*=\s*['\"][^'\"]{16,}['\"]"
    if ($hasHardcodedKey) {
        Write-Host "  ✗ Potential hardcoded key detected" -ForegroundColor $ErrorColor
        $Results.CriticalIssues++
        $Results.Recommendations += "Never hardcode encryption keys"
    } else {
        Write-Host "  ✓ No hardcoded keys detected" -ForegroundColor $SuccessColor
        $Score += 10
    }
    
    $Results.Checks += @{
        Name = "Key Storage Security"
        Passed = ($hasSecureStorage -and -not $hasHardcodedKey)
        Score = $(if($hasSecureStorage){15}else{0}) + $(if($hasAndroidOptions){5}else{0}) + $(if($hasIOSOptions){5}else{0}) + $(if(-not $hasHardcodedKey){10}else{0})
    }
    
    Write-Host ""
    
    # Check 4: Key Derivation
    Write-Host "Check 4: Key Derivation" -ForegroundColor $HeaderColor
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
    
    # Check for PBKDF2
    $hasPBKDF2 = $content -match "PBKDF2"
    if ($hasPBKDF2) {
        Write-Host "  ✓ PBKDF2 key derivation detected" -ForegroundColor $SuccessColor
        $Score += 10
    }
    
    # Check for scrypt
    $hasscrypt = $content -match "scrypt"
    if ($hasscrypt) {
        Write-Host "  ✓ scrypt key derivation detected" -ForegroundColor $SuccessColor
        $Score += 10
    }
    
    # Check for bcrypt
    $hasbcrypt = $content -match "bcrypt"
    if ($hasbcrypt) {
        Write-Host "  ✓ bcrypt key derivation detected" -ForegroundColor $SuccessColor
        $Score += 10
    }
    
    if (-not ($hasPBKDF2 -or $hasscrypt -or $hasbcrypt)) {
        Write-Host "  ⚠ No key derivation function detected" -ForegroundColor $WarningColor
        Write-Host "    Recommendation: Use PBKDF2 or scrypt for password-based key derivation" -ForegroundColor $InfoColor
        $Results.Recommendations += "Implement key derivation (PBKDF2/scrypt) for password-based encryption"
    }
    
    $Results.Checks += @{
        Name = "Key Derivation"
        Passed = ($hasPBKDF2 -or $hasscrypt -or $hasbcrypt)
        Score = $(if($hasPBKDF2){10}else{0}) + $(if($hasscrypt){10}else{0}) + $(if($hasbcrypt){10}else{0})
    }
    
    Write-Host ""
    
    # Check 5: Encryption/Decryption Methods
    Write-Host "Check 5: API Completeness" -ForegroundColor $HeaderColor
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
    
    $hasEncrypt = $content -match "encrypt\s*\("
    $hasDecrypt = $content -match "decrypt\s*\("
    $hasEncryptAsync = $content -match "encrypt.*async"
    $hasErrorHandling = $content -match "(try|catch|on)"
    
    if ($hasEncrypt) {
        Write-Host "  ✓ Encrypt method detected" -ForegroundColor $SuccessColor
        $Score += 5
    } else {
        Write-Host "  ✗ Encrypt method not found" -ForegroundColor $ErrorColor
    }
    
    if ($hasDecrypt) {
        Write-Host "  ✓ Decrypt method detected" -ForegroundColor $SuccessColor
        $Score += 5
    } else {
        Write-Host "  ✗ Decrypt method not found" -ForegroundColor $ErrorColor
    }
    
    if ($hasErrorHandling) {
        Write-Host "  ✓ Error handling detected" -ForegroundColor $SuccessColor
        $Score += 5
    } else {
        Write-Host "  ⚠ Error handling not detected" -ForegroundColor $WarningColor
    }
    
    $Results.Checks += @{
        Name = "API Completeness"
        Passed = ($hasEncrypt -and $hasDecrypt)
        Score = $(if($hasEncrypt){5}else{0}) + $(if($hasDecrypt){5}else{0}) + $(if($hasErrorHandling){5}else{0})
    }
    
    Write-Host ""
}

# Check 6: Pubspec Dependencies
Write-Host "Check 6: Dependencies" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$pubspecPath = "pubspec.yaml"
if (Test-Path $pubspecPath) {
    $pubspec = Get-Content $pubspecPath -Raw
    
    $hasEncryptPackage = $pubspec -match "encrypt:"
    $hasSecureStoragePackage = $pubspec -match "flutter_secure_storage:"
    $hasCryptoPackage = $pubspec -match "crypto:"
    
    if ($hasEncryptPackage) {
        Write-Host "  ✓ encrypt package dependency found" -ForegroundColor $SuccessColor
        $Score += 5
    } else {
        Write-Host "  ⚠ encrypt package not in dependencies" -ForegroundColor $WarningColor
        $Results.Recommendations += "Add encrypt package to pubspec.yaml"
    }
    
    if ($hasSecureStoragePackage) {
        Write-Host "  ✓ flutter_secure_storage package found" -ForegroundColor $SuccessColor
        $Score += 5
    } else {
        Write-Host "  ⚠ flutter_secure_storage package not in dependencies" -ForegroundColor $WarningColor
        $Results.Recommendations += "Add flutter_secure_storage package to pubspec.yaml"
    }
    
    if ($hasCryptoPackage) {
        Write-Host "  ✓ crypto package found" -ForegroundColor $SuccessColor
        $Score += 5
    }
}

$Results.Checks += @{
    Name = "Dependencies"
    Passed = ($hasEncryptPackage -and $hasSecureStoragePackage)
    Score = $(if($hasEncryptPackage){5}else{0}) + $(if($hasSecureStoragePackage){5}else{0})
}

Write-Host ""

# Calculate final score
$Results.Score = $Score
$Results.MaxScore = $MaxScore

# Determine status
if ($Score -ge 90) {
    $Results.Status = "Excellent"
    $StatusColor = $SuccessColor
} elseif ($Score -ge 70) {
    $Results.Status = "Good"
    $StatusColor = $InfoColor
} elseif ($Score -ge 50) {
    $Results.Status = "Needs Improvement"
    $StatusColor = $WarningColor
} else {
    $Results.Status = "Critical"
    $StatusColor = $ErrorColor
}

# Summary
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Encryption Audit Summary" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

Write-Host "  Score: $Score / $MaxScore" -ForegroundColor $(if($Score -ge 70){$SuccessColor}elseif($Score -ge 50){$WarningColor}else{$ErrorColor})
Write-Host "  Status: $($Results.Status)" -ForegroundColor $StatusColor
Write-Host ""

Write-Host "  Critical Issues: $($Results.CriticalIssues)" -ForegroundColor $(if($Results.CriticalIssues -eq 0){$SuccessColor}else{$CriticalColor})
Write-Host "  High Issues: $($Results.HighIssues)" -ForegroundColor $(if($Results.HighIssues -eq 0){$SuccessColor}else{$ErrorColor})
Write-Host ""

if ($Results.Recommendations.Count -gt 0) {
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Recommendations" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    $Results.Recommendations | ForEach-Object {
        Write-Host "  ⚠ $_" -ForegroundColor $WarningColor
    }
    
    Write-Host ""
}

if ($FixSuggestions) {
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Fix Suggestions" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    if (-not (Test-Path $encryptionServicePath)) {
        Write-Host "  1. Create encryption service:" -ForegroundColor $InfoColor
        Write-Host "     lib/core/services/encryption_service.dart" -ForegroundColor $InfoColor
        Write-Host "     - Use AES-256-CBC or AES-256-GCM" -ForegroundColor $InfoColor
        Write-Host "     - Store keys in flutter_secure_storage" -ForegroundColor $InfoColor
        Write-Host "     - Implement encrypt() and decrypt() methods" -ForegroundColor $InfoColor
        Write-Host ""
    }
    
    if ($Results.CriticalIssues -gt 0) {
        Write-Host "  2. Address critical issues immediately" -ForegroundColor $ErrorColor
        Write-Host "     - Never hardcode encryption keys" -ForegroundColor $ErrorColor
        Write-Host "     - Always use secure storage for keys" -ForegroundColor $ErrorColor
        Write-Host ""
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║         Encryption Audit Complete                         ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\encryption-audit-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    if (-not $Silent) { Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor }
}

if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

return $Results
