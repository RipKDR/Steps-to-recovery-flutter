# PII Leak Detector
# Scans for personally identifiable information leaks in code and logs

param(
    [switch]$Full,
    [switch]$Json,
    [string]$OutputPath,
    [switch]$Silent,
    [switch]$AutoFix
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
    Write-Host "║         PII Leak Detector                                 ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalLeaks = 0
    ByType = @{
        Phone = 0
        Email = 0
        SSN = 0
        CreditCard = 0
        Address = 0
        SensitiveLog = 0
    }
    Issues = @()
    Status = "Unknown"
}

# PII Patterns
$Patterns = @{
    Phone = "\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"
    Email = "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"
    SSN = "\b\d{3}-\d{2}-\d{4}\b"
    CreditCard = "\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b"
    Address = "\b\d+\s+[A-Za-z]+\s+(Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Drive|Dr|Lane|Ln)\b"
}

Write-Host "Scanning for PII leaks..." -ForegroundColor $InfoColor
Write-Host ""

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-Object -First 100

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    $lines = Get-Content $file.FullName -ErrorAction SilentlyContinue
    
    if (-not $content) { continue }
    
    foreach ($piiType in $Patterns.Keys) {
        $matches = [regex]::Matches($content, $Patterns[$piiType])
        
        if ($matches.Count -gt 0) {
            foreach ($match in $matches) {
                $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
                $line = $lines[$lineNumber - 1]
                
                # Check if in print/log statement
                $inLog = $line -match "(print|log|debug|info|warning|error)\s*\("
                
                if ($inLog) {
                    $Results.Issues += @{
                        File = $file.FullName
                        Line = $lineNumber
                        Type = $piiType
                        Severity = "High"
                        Issue = "PII in log statement"
                        Code = $line.Trim()
                    }
                    
                    $Results.TotalLeaks++
                    $Results.ByType[$piiType]++
                }
            }
        }
    }
    
    # Check for sensitive variable names in logs
    $sensitiveVars = @("phone", "email", "ssn", "creditCard", "address", "password", "token")
    foreach ($var in $sensitiveVars) {
        if ($content -match "(print|log|debug).*\b$var\b") {
            $Results.Issues += @{
                File = $file.FullName
                Type = "SensitiveLog"
                Severity = "Medium"
                Issue = "Sensitive variable '$var' logged"
            }
            $Results.TotalLeaks++
            $Results.ByType.SensitiveLog++
        }
    }
}

# Display results
if (-not $Silent) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  PII Leak Detection Results" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Total Leaks: $($Results.TotalLeaks)" -ForegroundColor $(if($Results.TotalLeaks -eq 0){$SuccessColor}else{$ErrorColor})
    Write-Host ""
    
    Write-Host "  By Type:" -ForegroundColor $HeaderColor
    foreach ($type in $Results.ByType.Keys) {
        $count = $Results.ByType[$type]
        Write-Host "    $type`: $count" -ForegroundColor $(if($count -eq 0){$SuccessColor}else{$WarningColor})
    }
    
    Write-Host ""
    
    if ($Results.Issues.Count -gt 0) {
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host "  Detected Issues" -ForegroundColor $ErrorColor
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host ""
        
        $Results.Issues | Select-Object -First 10 | ForEach-Object {
            Write-Host "  [$($_.Type)] $($_.File)" -ForegroundColor $ErrorColor
            Write-Host "    Line $($_.Line): $($_.Issue)" -ForegroundColor $WarningColor
            if ($_.Code) { Write-Host "    Code: $($_.Code)" -ForegroundColor $InfoColor }
            Write-Host ""
        }
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         PII Leak Detection Complete                       ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
}

$Results.Status = if ($Results.TotalLeaks -eq 0) { "All Clear" } else { "Leaks Detected" }

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\pii-leaks-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
}

if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

return $Results
