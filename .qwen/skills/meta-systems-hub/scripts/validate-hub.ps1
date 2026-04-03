# Validate Meta-Systems Hub Installation
# Checks all required files, directories, and dependencies

param(
    [switch]$Full,
    [switch]$Json,
    [string]$OutputPath
)

$ErrorActionPreference = "Continue"

# Colors
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"
$HeaderColor = "Cyan"

# Paths
$HubPath = ".qwen\skills\meta-systems-hub"
$SelfEvolvingPath = ".qwen\skills\self-evolving-agent"

# Results
$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Checks = @()
    Passed = 0
    Failed = 0
    Warnings = 0
}

function Add-CheckResult {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Message = "",
        [string]$Fix = ""
    )
    
    $result = @{
        Name = $Name
        Passed = $Passed
        Message = $Message
        Fix = $Fix
    }
    
    $Results.Checks += $result
    
    if ($Passed) {
        $Results.Passed++
        Write-Host "    ✓ $Message" -ForegroundColor $SuccessColor
    } else {
        $Results.Failed++
        Write-Host "    ✗ $Message" -ForegroundColor $ErrorColor
        if ($Fix) {
            Write-Host "      Fix: $Fix" -ForegroundColor $InfoColor
        }
    }
}

function Add-CheckWarning {
    param(
        [string]$Name,
        [string]$Message
    )
    
    $result = @{
        Name = $Name
        Passed = $true
        Message = $Message
        IsWarning = $true
    }
    
    $Results.Checks += $result
    $Results.Warnings++
    Write-Host "    ⚠ $Message" -ForegroundColor $WarningColor
}

# Start validation
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║   Meta-Systems Hub Validation                             ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# Check 1: Directory Structure
Write-Host "[1/8] Directory Structure" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$dirs = @(
    "$HubPath",
    "$HubPath\modules",
    "$HubPath\modules\code-health",
    "$HubPath\modules\security-plus",
    "$HubPath\modules\test-coverage",
    "$HubPath\scripts",
    "$HubPath\references",
    "$HubPath\logs"
)

foreach ($dir in $dirs) {
    $exists = Test-Path $dir
    $dirName = $dir -replace [regex]::Escape("$HubPath\"), ""
    Add-CheckResult -Name "Directory: $dirName" -Passed $exists -Message "$(if($exists){"$dirName exists"}else{"$dirName missing"})" -Fix "Create directory: $dir"
}

Write-Host ""

# Check 2: Core Files
Write-Host "[2/8] Core Files" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$coreFiles = @(
    "$HubPath\SKILL.md",
    "$HubPath\README.md",
    "$HubPath\config.json"
)

foreach ($file in $coreFiles) {
    $exists = Test-Path $file
    $fileName = $file -replace [regex]::Escape("$HubPath\"), ""
    Add-CheckResult -Name "File: $fileName" -Passed $exists -Message "$(if($exists){"$fileName exists"}else{"$fileName missing"})" -Fix "Create file: $file"
}

Write-Host ""

# Check 3: Hub Scripts
Write-Host "[3/8] Hub Coordination Scripts" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$hubScripts = @(
    "meta-dashboard.ps1",
    "run-all-scans.ps1",
    "daily-health-report.ps1",
    "pre-commit-enhanced.ps1"
)

foreach ($script in $hubScripts) {
    $path = "$HubPath\scripts\$script"
    $exists = Test-Path $path
    Add-CheckResult -Name "Script: $script" -Passed $exists -Message "$(if($exists){"$script exists"}else{"$script missing"})" -Fix "Create script: $path"
}

Write-Host ""

# Check 4: Module Scripts
Write-Host "[4/8] Module Scripts" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$moduleScripts = @(
    "modules\code-health\scripts\analyze-with-context.ps1",
    "modules\code-health\scripts\auto-fix-safe.ps1",
    "modules\security-plus\scripts\local-security-scan.ps1",
    "modules\test-coverage\scripts\coverage-analyzer.ps1"
)

foreach ($script in $moduleScripts) {
    $path = "$HubPath\$script"
    $exists = Test-Path $path
    $scriptName = $script -replace "modules\\[^\\]+\\scripts\\", ""
    Add-CheckResult -Name "Module Script: $scriptName" -Passed $exists -Message "$(if($exists){"$scriptName exists"}else{"$scriptName missing (Phase 2/3/4)"})" -Fix "Will be created in Phase 2/3/4"
}

Write-Host ""

# Check 5: Configuration
Write-Host "[5/8] Configuration" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

$configPath = "$HubPath\config.json"
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        Add-CheckResult -Name "Config JSON" -Passed $true -Message "config.json is valid JSON"
        
        # Check required fields
        $requiredFields = @("enabled", "modules", "integration", "reporting")
        foreach ($field in $requiredFields) {
            $hasField = $config.PSObject.Properties.Name -contains $field
            Add-CheckResult -Name "Config: $field" -Passed $hasField -Message "$(if($hasField){"$field present"}else{"$field missing"})"
        }
    } catch {
        Add-CheckResult -Name "Config JSON" -Passed $false -Message "config.json is invalid JSON" -Fix "Fix JSON syntax in config.json"
    }
} else {
    Add-CheckResult -Name "Config JSON" -Passed $false -Message "config.json not found" -Fix "Create config.json"
}

Write-Host ""

# Check 6: Dependencies
Write-Host "[6/8] External Dependencies" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

# Check Flutter
try {
    $flutterVersion = & flutter --version 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        Add-CheckResult -Name "Flutter" -Passed $true -Message "Flutter is installed"
    } else {
        Add-CheckResult -Name "Flutter" -Passed $false -Message "Flutter not found" -Fix "Install Flutter: https://docs.flutter.dev/get-started/install"
    }
} catch {
    Add-CheckResult -Name "Flutter" -Passed $false -Message "Flutter not found" -Fix "Install Flutter"
}

# Check Git
try {
    $gitVersion = & git --version 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        Add-CheckResult -Name "Git" -Passed $true -Message "Git is installed"
    } else {
        Add-CheckResult -Name "Git" -Passed $false -Message "Git not found" -Fix "Install Git: https://git-scm.com/download/win"
    }
} catch {
    Add-CheckResult -Name "Git" -Passed $false -Message "Git not found" -Fix "Install Git"
}

Write-Host ""

# Check 7: Integration
Write-Host "[7/8] Integration with Existing Systems" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

# Check self-evolving-agent
$selfEvolvingExists = Test-Path $SelfEvolvingPath
Add-CheckResult -Name "Self-Evolving Agent" -Passed $selfEvolvingExists -Message "$(if($selfEvolvingExists){"self-evolving-agent exists"}else{"self-evolving-agent not found"})" -Fix "Install self-evolving-agent skill"

# Check GitHub Actions
$ciExists = Test-Path ".github\workflows\ci.yml"
$prExists = Test-Path ".github\workflows\pr_check.yml"
$securityExists = Test-Path ".github\workflows\security.yml"

Add-CheckResult -Name "CI Workflow" -Passed $ciExists -Message "$(if($ciExists){"ci.yml exists"}else{"ci.yml not found"})"
Add-CheckResult -Name "PR Check Workflow" -Passed $prExists -Message "$(if($prExists){"pr_check.yml exists"}else{"pr_check.yml not found"})"
Add-CheckResult -Name "Security Workflow" -Passed $securityExists -Message "$(if($securityExists){"security.yml exists"}else{"security.yml not found"})"

Write-Host ""

# Check 8: PowerShell Execution Policy
Write-Host "[8/8] PowerShell Configuration" -ForegroundColor $HeaderColor
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor $InfoColor

try {
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($executionPolicy -eq "Unrestricted" -or $executionPolicy -eq "RemoteSigned") {
        Add-CheckResult -Name "Execution Policy" -Passed $true -Message "Execution policy allows scripts ($executionPolicy)"
    } else {
        Add-CheckResult -Name "Execution Policy" -Passed $false -Message "Execution policy blocks scripts ($executionPolicy)" -Fix "Run: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"
    }
} catch {
    Add-CheckResult -Name "Execution Policy" -Passed $false -Message "Could not determine execution policy" -Fix "Manually check execution policy"
}

Write-Host ""

# Summary
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║   Validation Summary                                      ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

$Results.Duration = "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"

Write-Host "  Passed:   $($Results.Passed)" -ForegroundColor $SuccessColor
Write-Host "  Failed:   $($Results.Failed)" -ForegroundColor $(if($Results.Failed -eq 0){$SuccessColor}else{$ErrorColor})
Write-Host "  Warnings: $($Results.Warnings)" -ForegroundColor $WarningColor
Write-Host ""

if ($Results.Failed -eq 0) {
    Write-Host "  ✓ All critical checks passed!" -ForegroundColor $SuccessColor
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor $InfoColor
    Write-Host "  1. Run: .\.qwen\skills\meta-systems-hub\scripts\meta-dashboard.ps1" -ForegroundColor $InfoColor
    Write-Host "  2. Run: .\.qwen\skills\meta-systems-hub\scripts\run-all-scans.ps1" -ForegroundColor $InfoColor
    Write-Host ""
} else {
    Write-Host "  ✗ $($Results.Failed) checks failed - please fix before continuing" -ForegroundColor $ErrorColor
    Write-Host ""
}

# Save results
if ($OutputPath) {
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor
}

# JSON output
if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

# Exit code
if ($Results.Failed -gt 0) {
    exit 1
} else {
    exit 0
}
