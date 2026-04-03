# Meta-Systems Dashboard v2.0
# Enhanced unified dashboard with real-time data, trends, and quick actions

param(
    [switch]$Full,
    [switch]$Json,
    [switch]$Interactive,
    [string]$OutputPath,
    [switch]$NoCache,
    [switch]$ExportHtml
)

$ErrorActionPreference = "Continue"

# Colors
$HeaderColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"
$CriticalColor = "Magenta"
$HighlightColor = "Blue"

# Paths
$HubPath = ".qwen\skills\meta-systems-hub"
$CodeHealthPath = "$HubPath\modules\code-health"
$SecurityPath = "$HubPath\modules\security-plus"
$TestPath = "$HubPath\modules\test-coverage"
$LogsPath = "$HubPath\logs"
$CachePath = "$LogsPath\dashboard-cache.json"

# Ensure logs directory exists
if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

# Load cached data if available
$Cache = $null
if ((Test-Path $CachePath) -and -not $NoCache) {
    try {
        $Cache = Get-Content $CachePath -Raw | ConvertFrom-Json
    } catch {
        $Cache = $null
    }
}

# Helper Functions
function Write-Header {
    param([string]$Text, [string]$SubText = "")
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║  $Text" -ForegroundColor $HeaderColor
    if ($SubText) {
        Write-Host "║  $SubText" -ForegroundColor $InfoColor
    }
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

function Write-Status {
    param(
        [string]$Label,
        [string]$Status,
        [string]$Details = "",
        [string]$ColorOverride = ""
    )
    
    $color = if ($ColorOverride) { $ColorOverride } else {
        switch -Regex ($Status) {
            "^✓|Excellent|All Clear|Pass" { $SuccessColor }
            "^✗|Critical|Fail" { $ErrorColor }
            "^⚠|Warning|Needs" { $WarningColor }
            default { $InfoColor }
        }
    }
    
    Write-Host "  $(": ".PadRight(1)) $Label`: " -NoNewline
    Write-Host "$Status" -ForegroundColor $color -NoNewline
    
    if ($Details) {
        Write-Host " $Details" -ForegroundColor $InfoColor
    } else {
        Write-Host ""
    }
}

function Write-ProgressBar {
    param(
        [int]$Value,
        [int]$Max = 100,
        [int]$Width = 30,
        [string]$Label = ""
    )
    
    $percent = [math]::Min(100, [math]::Round(($Value / $Max) * 100, 1))
    $filled = [math]::Min($Width, [math]::Round(($Value / $Max) * $Width))
    $empty = [math]::Max(0, $Width - $filled)
    
    $bar = "[" + ("█" * $filled) + ("░" * $empty) + "]"
    
    $color = if ($percent -ge 80) { $SuccessColor } elseif ($percent -ge 50) { $WarningColor } else { $ErrorColor }
    
    if ($Label) {
        Write-Host "  $Label".PadRight(20) -NoNewline
    }
    Write-Host " $bar " -NoNewline
    Write-Host "$percent%" -ForegroundColor $color
}

function Get-TrendIndicator {
    param([float]$Current, [float]$Previous)
    
    if ($Previous -eq 0) { return "  (New)" }
    
    $change = [math]::Round($Current - $Previous, 1)
    $percentChange = [math]::Round(($change / $Previous) * 100, 1)
    
    if ($change -gt 0) {
        return " ↑ +$percentChange%" 
    } elseif ($change -lt 0) {
        return " ↓ $percentChange%"
    } else {
        return "  (No change)"
    }
}

function Get-CodeHealthStatus {
    # Check if flutter analyze passes
    $analyzeOutput = & flutter analyze 2>&1 | Out-String
    
    $issueCount = ($analyzeOutput | Select-String "issue" -CaseSensitive).Count
    $errorCount = ($analyzeOutput | Select-String "error" -CaseSensitive).Count
    $warningCount = ($analyzeOutput | Select-String "warning" -CaseSensitive).Count
    
    # Get historical data for trend
    $previousErrors = 0
    $trend = ""
    if ($Cache -and $Cache.CodeHealth) {
        $previousErrors = $Cache.CodeHealth.Errors
        if ($errorCount -lt $previousErrors) {
            $trend = " ↑ Improving"
        } elseif ($errorCount -gt $previousErrors) {
            $trend = " ↓ Worsening"
        }
    }
    
    if ($errorCount -eq 0 -and $warningCount -eq 0) {
        return @{ Status = "✓ Excellent"; Score = 100; Issues = 0; Trend = $trend }
    } elseif ($errorCount -eq 0) {
        return @{ Status = "✓ Good"; Score = 95; Issues = $warningCount; Trend = $trend }
    } else {
        $score = [math]::Max(0, 100 - ($errorCount * 5))
        return @{ Status = "⚠ Needs Work"; Score = $score; Issues = $errorCount + $warningCount; Trend = $trend }
    }
}

function Get-SecurityStatus {
    # Check for encryption service
    $encryptionExists = Test-Path "lib\core\services\encryption_service.dart"
    
    # Check for secure storage
    $secureStorageExists = (Get-Content "pubspec.yaml" -Raw) -match "flutter_secure_storage"
    
    # Quick PII check
    $piiIssues = 0
    $dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue | Select-Object -First 50
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match "(print|log|debug).*(phone|email|password|token)") {
            $piiIssues++
        }
    }
    
    $score = 100
    if (-not $encryptionExists) { $score -= 40 }
    if (-not $secureStorageExists) { $score -= 30 }
    if ($piiIssues -gt 0) { $score -= ($piiIssues * 10) }
    $score = [math]::Max(0, $score)
    
    if ($score -ge 90) {
        return @{ Status = "✓ All Clear"; Score = $score; Encryption = "Valid"; PII = "$piiIssues issues" }
    } else {
        return @{ Status = "⚠ Review Needed"; Score = $score; Encryption = $(if($encryptionExists){"Valid"}else{"Missing"}); PII = "$piiIssues issues" }
    }
}

function Get-TestCoverageStatus {
    # Try to get coverage from lcov.info if it exists
    $lcovPath = "coverage/lcov.info"
    
    if (Test-Path $lcovPath) {
        $lcovContent = Get-Content $lcovPath -Raw
        $totalLines = ($lcovContent | Select-String "DA:").Count
        $hitLines = ($lcovContent | Select-String "DA:.*,1").Count
        
        if ($totalLines -gt 0) {
            $coverage = [math]::Round(($hitLines / $totalLines) * 100, 1)
            
            # Get previous coverage for trend
            $previousCoverage = 0
            $trend = ""
            if ($Cache -and $Cache.TestCoverage) {
                $previousCoverage = $Cache.TestCoverage.Coverage
                $trend = Get-TrendIndicator -Current $coverage -Previous $previousCoverage
            }
            
            return @{ Status = "$coverage%$trend"; Target = "80%"; Score = $coverage }
        }
    }
    
    # Fallback: estimate from test file count
    $testFiles = Get-ChildItem -Path "test" -Recurse -Filter "*_test.dart" | Measure-Object | Select-Object -ExpandProperty Count
    $libFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Measure-Object | Select-Object -ExpandProperty Count
    
    if ($libFiles -gt 0) {
        $estimatedCoverage = [math]::Min(85, ($testFiles / $libFiles) * 100)
        return @{ Status = "~$estimatedCoverage% (est)"; Target = "80%"; Score = $estimatedCoverage }
    }
    
    return @{ Status = "Unknown"; Target = "80%"; Score = 0 }
}

function Get-CICDStatus {
    # Check GitHub Actions workflow files
    $ciExists = Test-Path ".github\workflows\ci.yml"
    $prExists = Test-Path ".github\workflows\pr_check.yml"
    $securityExists = Test-Path ".github\workflows\security.yml"
    
    $workflowCount = @($ciExists,$prExists,$securityExists).Where({$_}).Count
    
    if ($workflowCount -eq 3) {
        return @{ Status = "✓ Configured"; Workflows = $workflowCount; Score = 100 }
    } else {
        return @{ Status = "⚠ Partial"; Workflows = $workflowCount; Score = ($workflowCount * 33) }
    }
}

function Get-QuickActions {
    param($CodeHealth, $Security, $TestCoverage)
    
    $actions = @()
    
    if ($CodeHealth.Issues -gt 0) {
        $actions += @{
            Command = ".\.qwen\skills\meta-systems-hub\modules\code-health\scripts\auto-fix-safe.ps1"
            Description = "Auto-fix $($CodeHealth.Issues) code issues"
            Priority = "High"
            Module = "Code Health"
        }
    }
    
    if ($Security.PII -like "*issues*" -and $Security.PII -notlike "0 issues") {
        $actions += @{
            Command = ".\.qwen\skills\meta-systems-hub\modules\security-plus\scripts\pii-leak-detector.ps1"
            Description = "Review PII leaks"
            Priority = "Critical"
            Module = "Security"
        }
    }
    
    if ($TestCoverage.Score -lt 50) {
        $actions += @{
            Command = ".\.qwen\skills\meta-systems-hub\modules\test-coverage\scripts\generate-unit-tests.ps1 -All"
            Description = "Generate tests for untested code"
            Priority = "Medium"
            Module = "Test Coverage"
        }
    }
    
    if ($CodeHealth.Issues -eq 0 -and $Security.Score -ge 90 -and $TestCoverage.Score -ge 80) {
        $actions += @{
            Command = "echo 'All systems operational!'"
            Description = "✓ All systems operational - no actions needed"
            Priority = "Info"
            Module = "System"
        }
    }
    
    return $actions
}

# Main Dashboard
Write-Header "Meta-Systems Dashboard" "Real-time status, trends, and quick actions"
Write-Host "  Last Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $InfoColor
Write-Host ""

# Collect all metrics
$codeHealth = Get-CodeHealthStatus
$security = Get-SecurityStatus
$testCoverage = Get-TestCoverageStatus
$cicd = Get-CICDStatus
$quickActions = Get-QuickActions -CodeHealth $codeHealth -Security $security -TestCoverage $testCoverage

# Calculate overall score
$overallScore = [math]::Round(($codeHealth.Score + $security.Score + $testCoverage.Score + $cicd.Score) / 4, 1)

# Overall System Health
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Overall System Health" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

Write-ProgressBar -Value $overallScore -Label "System Health"
Write-Host ""

# Code Health Module
Write-Host "Code Health Module" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
Write-Status "Status" $codeHealth.Status "" $(if($codeHealth.Score -ge 90){$SuccessColor}elseif($codeHealth.Score -ge 70){$WarningColor}else{$ErrorColor})
Write-Status "Issues" "$($codeHealth.Issues) found" "" $(if($codeHealth.Issues -eq 0){$SuccessColor}else{$WarningColor})
if ($codeHealth.Trend) {
    Write-Status "Trend" $codeHealth.Trend "" $InfoColor
}
Write-ProgressBar -Value $codeHealth.Score -Label "Health Score"
Write-Host ""

# Security Plus Module
Write-Host "Security Plus Module" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
Write-Status "Status" $security.Status "" $(if($security.Score -ge 90){$SuccessColor}elseif($security.Score -ge 70){$WarningColor}else{$ErrorColor})
Write-Status "Encryption" $security.Encryption "" $(if($security.Encryption -eq "Valid"){$SuccessColor}else{$ErrorColor})
Write-Status "PII Leaks" $security.PII "" $(if($security.PII -like "0*"){$SuccessColor}else{$WarningColor})
Write-ProgressBar -Value $security.Score -Label "Security Score"
Write-Host ""

# Test Coverage Module
Write-Host "Test Coverage Module" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
Write-Status "Coverage" $testCoverage.Status "Target: $($testCoverage.Target)" $(if($testCoverage.Score -ge 80){$SuccessColor}elseif($testCoverage.Score -ge 50){$WarningColor}else{$ErrorColor})
Write-ProgressBar -Value $testCoverage.Score -Max 80 -Label "Progress to 80%"
Write-Host ""

# CI/CD Integration
Write-Host "CI/CD Integration" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor
Write-Status "Status" $cicd.Status "$($cicd.Workflows)/3 workflows" $(if($cicd.Workflows -eq 3){$SuccessColor}else{$WarningColor})
Write-Host ""

# Quick Actions
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Quick Actions" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

$actionNum = 1
foreach ($action in $quickActions) {
    $priorityColor = switch ($action.Priority) {
        "Critical" { $CriticalColor }
        "High" { $ErrorColor }
        "Medium" { $WarningColor }
        "Info" { $SuccessColor }
        default { $InfoColor }
    }
    
    Write-Host "  [$actionNum] $($action.Description)" -ForegroundColor $priorityColor
    Write-Host "      Module: $($action.Module) | Priority: $($action.Priority)" -ForegroundColor $InfoColor
    Write-Host "      Command: $($action.Command)" -ForegroundColor $InfoColor
    Write-Host ""
    $actionNum++
}

# Interactive mode
if ($Interactive) {
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Interactive Mode" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    Write-Host "  Select an action to execute (1-$($quickActions.Count), or 'q' to quit):" -ForegroundColor $InfoColor
    
    $choice = Read-Host "  Enter choice"
    
    if ($choice -match "^\d+$" -and $choice -ge 1 -and $choice -le $quickActions.Count) {
        $selectedAction = $quickActions[$choice - 1]
        Write-Host ""
        Write-Host "  Executing: $($selectedAction.Description)" -ForegroundColor $HeaderColor
        Write-Host ""
        
        Invoke-Expression $selectedAction.Command
    } elseif ($choice -ne "q") {
        Write-Host "  Invalid choice" -ForegroundColor $WarningColor
    }
    
    Write-Host ""
}

# Save to cache
$cacheData = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    OverallScore = $overallScore
    CodeHealth = @{
        Score = $codeHealth.Score
        Issues = $codeHealth.Issues
        Errors = ($codeHealth.Issues)
    }
    Security = @{
        Score = $security.Score
        PII = $security.PII
    }
    TestCoverage = @{
        Coverage = $testCoverage.Score
    }
}

$cacheData | ConvertTo-Json | Out-File -FilePath $CachePath -Encoding utf8

# Save to file if requested
if ($OutputPath) {
    $cacheData | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "Dashboard saved to: $OutputPath" -ForegroundColor $InfoColor
}

# Export HTML if requested
if ($ExportHtml) {
    $htmlPath = "$LogsPath\dashboard-$(Get-Date -Format 'yyyy-MM-dd').html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Meta-Systems Dashboard - $(Get-Date -Format 'yyyy-MM-dd')</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #1a1a2e; color: #eee; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .metric { background: #16213e; padding: 20px; margin: 10px 0; border-radius: 8px; }
        .metric h3 { margin: 0 0 10px 0; color: #00d9ff; }
        .score { font-size: 2em; font-weight: bold; }
        .good { color: #00ff88; }
        .warning { color: #ffaa00; }
        .critical { color: #ff4444; }
        .progress { background: #0f3460; height: 20px; border-radius: 10px; overflow: hidden; margin: 10px 0; }
        .progress-bar { height: 100%; background: linear-gradient(90deg, #00d9ff, #00ff88); }
    </style>
</head>
<body>
    <div class="header">
        <h1>Meta-Systems Dashboard</h1>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
    
    <div class="metric">
        <h3>Overall System Health</h3>
        <div class="score $(if($overallScore -ge 80){'good'}elseif($overallScore -ge 50){'warning'}else{'critical'})">$overallScore%</div>
        <div class="progress"><div class="progress-bar" style="width: $overallScore%"></div></div>
    </div>
    
    <div class="metric">
        <h3>Code Health</h3>
        <p>Status: $($codeHealth.Status)</p>
        <p>Issues: $($codeHealth.Issues)</p>
        <div class="progress"><div class="progress-bar" style="width: $($codeHealth.Score)%"></div></div>
    </div>
    
    <div class="metric">
        <h3>Security</h3>
        <p>Status: $($security.Status)</p>
        <p>Encryption: $($security.Encryption)</p>
        <p>PII Leaks: $($security.PII)</p>
        <div class="progress"><div class="progress-bar" style="width: $($security.Score)%"></div></div>
    </div>
    
    <div class="metric">
        <h3>Test Coverage</h3>
        <p>Coverage: $($testCoverage.Status)</p>
        <div class="progress"><div class="progress-bar" style="width: $($testCoverage.Score)%"></div></div>
    </div>
</body>
</html>
"@
    
    $html | Out-File -FilePath $htmlPath -Encoding utf8
    Write-Host "HTML dashboard exported to: $htmlPath" -ForegroundColor $InfoColor
}

Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $InfoColor
Write-Host "Run '.\.qwen\skills\meta-systems-hub\scripts\run-all-scans.ps1' for full scan" -ForegroundColor $InfoColor
Write-Host "Use -Interactive flag for executable actions" -ForegroundColor $InfoColor
Write-Host ""
