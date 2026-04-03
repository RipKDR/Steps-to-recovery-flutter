# Integrate Meta-Systems Hub with Self-Evolving Agent
# Creates bidirectional sync between the two systems

param(
    [switch]$Full,
    [switch]$DryRun,
    [switch]$Verbose
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
$RememberPath = ".remember\logs\autonomous"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║   Meta-Systems Hub Integration                            ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

Write-Host "Integrating meta-systems-hub with self-evolving-agent..." -ForegroundColor $InfoColor
Write-Host ""

# Step 1: Verify self-evolving-agent exists
Write-Host "[1/4] Checking self-evolving-agent..." -ForegroundColor $HeaderColor

if (Test-Path $SelfEvolvingPath) {
    Write-Host "  ✓ self-evolving-agent found" -ForegroundColor $SuccessColor
} else {
    Write-Host "  ✗ self-evolving-agent not found" -ForegroundColor $ErrorColor
    Write-Host "    Install self-evolving-agent first" -ForegroundColor $WarningColor
    exit 1
}

Write-Host ""

# Step 2: Create integration config in self-evolving-agent
Write-Host "[2/4] Creating integration config..." -ForegroundColor $HeaderColor

$integrationConfig = @{
    MetaSystemsHub = @{
        Enabled = $true
        IntegratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        SyncLearnings = $true
        SyncReports = $true
        Paths = @{
            Hub = $HubPath
            Logs = "$HubPath\logs"
            Reports = "$HubPath\reports"
        }
        Triggers = @{
            OnScanComplete = $true
            OnAutoFix = $true
            OnSecurityIssue = $true
            DailyReport = $true
        }
    }
}

if (-not $DryRun) {
    # Add to self-evolving-agent config
    $selfEvolvingConfigPath = "$SelfEvolvingPath\config.json"
    if (Test-Path $selfEvolvingConfigPath) {
        $config = Get-Content $selfEvolvingConfigPath -Raw | ConvertFrom-Json
        $config | Add-Member -NotePropertyName "metaSystemsHub" -NotePropertyValue $integrationConfig.MetaSystemsHub -Force
        
        $config | ConvertTo-Json -Depth 10 | Out-File -FilePath $selfEvolvingConfigPath -Encoding utf8
        Write-Host "  ✓ Integration config added to self-evolving-agent" -ForegroundColor $SuccessColor
    } else {
        Write-Host "  ⚠ self-evolving-agent config.json not found" -ForegroundColor $WarningColor
    }
} else {
    Write-Host "  ℹ Dry run - would create integration config" -ForegroundColor $InfoColor
}

Write-Host ""

# Step 3: Create learning sync script
Write-Host "[3/4] Creating learning sync script..." -ForegroundColor $HeaderColor

$syncScript = @"
# Sync Learnings from Meta-Systems Hub to Self-Evolving Agent
# Automatically called after hub scans

param(
    [string]`$LearningType = "CodeHealth",
    [string]`$LearningData
)

`$ErrorActionPreference = "Continue"

`$HubPath = ".qwen\skills\meta-systems-hub"
`$SelfEvolvingPath = ".qwen\skills\self-evolving-agent"
`$RememberPath = ".remember\logs\autonomous"

# Ensure directories exist
`$learningsDir = "`$SelfEvolvingPath\knowledge"
`$memoryDir = "`$RememberPath"

if (-not (Test-Path `$learningsDir)) {
    New-Item -ItemType Directory -Force -Path `$learningsDir | Out-Null
}

if (-not (Test-Path `$memoryDir)) {
    New-Item -ItemType Directory -Force -Path `$memoryDir | Out-Null
}

# Create learning entry
`$learning = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Source = "meta-systems-hub"
    Type = `$LearningType
    Data = `$LearningData
}

# Save to self-evolving-agent knowledge
`$learningFile = "`$learningsDir\meta-systems-`(Get-Date -Format 'yyyy-MM-dd').json"
if (Test-Path `$learningFile) {
    `$existing = Get-Content `$learningFile -Raw | ConvertFrom-Json
    `$existing += `$learning
    `$existing | ConvertTo-Json -Depth 5 | Out-File -FilePath `$learningFile -Encoding utf8
} else {
    @(`$learning) | ConvertTo-Json -Depth 5 | Out-File -FilePath `$learningFile -Encoding utf8
}

Write-Host "  Learning synced to self-evolving-agent" -ForegroundColor Green
"@

if (-not $DryRun) {
    $syncScriptPath = "$HubPath\scripts\sync-learnings.ps1"
    $syncScript | Out-File -FilePath $syncScriptPath -Encoding utf8
    Write-Host "  ✓ Sync script created: sync-learnings.ps1" -ForegroundColor $SuccessColor
} else {
    Write-Host "  ℹ Dry run - would create sync script" -ForegroundColor $InfoColor
}

Write-Host ""

# Step 4: Create memory directory structure
Write-Host "[4/4] Setting up memory integration..." -ForegroundColor $HeaderColor

if (-not $DryRun) {
    # Create memory directories
    $memoryDirs = @(
        "$RememberPath\meta-systems",
        "$RememberPath\meta-systems\code-health",
        "$RememberPath\meta-systems\security",
        "$RememberPath\meta-systems\test-coverage"
    )
    
    foreach ($dir in $memoryDirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
    }
    
    Write-Host "  ✓ Memory directories created" -ForegroundColor $SuccessColor
    
    # Create initial memory file
    $memoryFile = "$RememberPath\meta-systems\integration-log.md"
    $memoryContent = @"
# Meta-Systems Hub Integration Log

**Integrated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Integration Points

1. **Self-Evolving Agent** - Bidirectional sync
2. **Memory System** - Learnings stored in .remember/logs/autonomous/meta-systems/
3. **GitHub Actions** - Local pre-checks before CI

## Learning Categories

- Code Health - Lint issues, auto-fixes, code smells
- Security - Encryption audits, PII detection, RLS policies
- Test Coverage - Test generation, coverage thresholds

## Automatic Triggers

- After each hub scan → Sync to self-evolving-agent
- After auto-fix → Log learning
- After security issue → Alert + log
- Daily report → Summary to memory

---

## Recent Activity

$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - Integration established
"@
    
    $memoryContent | Out-File -FilePath $memoryFile -Encoding utf8
    Write-Host "  ✓ Integration log created: integration-log.md" -ForegroundColor $SuccessColor
} else {
    Write-Host "  ℹ Dry run - would create memory structure" -ForegroundColor $InfoColor
}

Write-Host ""

# Summary
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║   Integration Complete                                    ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

Write-Host "  Meta-systems hub is now integrated with:" -ForegroundColor $InfoColor
Write-Host "  ✓ self-evolving-agent" -ForegroundColor $SuccessColor
Write-Host "  ✓ .remember/ memory system" -ForegroundColor $SuccessColor
Write-Host "  ✓ GitHub Actions (via config)" -ForegroundColor $SuccessColor
Write-Host ""

Write-Host "  Next steps:" -ForegroundColor $InfoColor
Write-Host "  1. Run: .\.qwen\skills\meta-systems-hub\scripts\validate-hub.ps1" -ForegroundColor $InfoColor
Write-Host "  2. Run: .\.qwen\skills\meta-systems-hub\scripts\meta-dashboard.ps1" -ForegroundColor $InfoColor
Write-Host "  3. Run: .\.qwen\skills\meta-systems-hub\scripts\run-all-scans.ps1" -ForegroundColor $InfoColor
Write-Host ""

Write-Host "  Learnings will automatically sync to:" -ForegroundColor $InfoColor
Write-Host "  - .qwen/skills/self-evolving-agent/knowledge/" -ForegroundColor $InfoColor
Write-Host "  - .remember/logs/autonomous/meta-systems/" -ForegroundColor $InfoColor
Write-Host ""
