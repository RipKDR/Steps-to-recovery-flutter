# Storage Privacy Scanner
# Scans for plaintext sensitive data storage

param(
    [switch]$Full,
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

# Paths
$SecurityPath = ".qwen\skills\meta-systems-hub\modules\security-plus"
$LogsPath = "$SecurityPath\reports"

if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Storage Privacy Scanner                           ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalIssues = 0
    ByFeature = @{
        Journal = 0
        Inventory = 0
        Sponsor = 0
        Steps = 0
        Crisis = 0
    }
    Issues = @()
    Status = "Unknown"
}

Write-Host "Scanning sensitive data storage..." -ForegroundColor $InfoColor
Write-Host ""

$sensitiveFeatures = @("journal", "inventory", "sponsor", "step", "crisis")

foreach ($feature in $sensitiveFeatures) {
    $featureFiles = Get-ChildItem -Path "lib\features" -Recurse -Filter "*$feature*.dart" -ErrorAction SilentlyContinue
    
    foreach ($file in $featureFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        
        if (-not $content) { continue }
        
        # Check for plaintext storage
        $hasStorage = $content -match "(SharedPreferences|setString|setInt|setBool|database_service)"
        $hasEncryption = $content -match "(encrypt|Encrypt|EncryptionService|encryption_service)"
        
        if ($hasStorage -and -not $hasEncryption) {
            $Results.Issues += @{
                File = $file.FullName
                Feature = $feature
                Severity = "Critical"
                Issue = "Sensitive data stored without encryption"
                Recommendation = "Encrypt data before storage using EncryptionService"
            }
            $Results.TotalIssues++
            $Results.ByFeature[$feature]++
        }
    }
}

# Display results
if (-not $Silent) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Storage Privacy Results" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Total Issues: $($Results.TotalIssues)" -ForegroundColor $(if($Results.TotalIssues -eq 0){$SuccessColor}else{$ErrorColor})
    Write-Host ""
    
    Write-Host "  By Feature:" -ForegroundColor $HeaderColor
    foreach ($feature in $Results.ByFeature.Keys) {
        $count = $Results.ByFeature[$feature]
        Write-Host "    $feature`: $count" -ForegroundColor $(if($count -eq 0){$SuccessColor}else{$ErrorColor})
    }
    
    Write-Host ""
    
    if ($Results.Issues.Count -gt 0) {
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host "  Critical Issues" -ForegroundColor $ErrorColor
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host ""
        
        $Results.Issues | Select-Object -First 10 | ForEach-Object {
            Write-Host "  [$($_.Feature)] $($_.File)" -ForegroundColor $ErrorColor
            Write-Host "    Issue: $($_.Issue)" -ForegroundColor $WarningColor
            Write-Host "    Fix: $($_.Recommendation)" -ForegroundColor $InfoColor
            Write-Host ""
        }
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Storage Privacy Scan Complete                     ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
}

$Results.Status = if ($Results.TotalIssues -eq 0) { "All Clear" } else { "Issues Found" }

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\storage-privacy-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
}

if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

return $Results
