# Analyze Code with Context
# Runs flutter analyze with historical pattern tracking

param(
    [switch]$Full,
    [switch]$Json,
    [string]$OutputPath,
    [switch]$CompareWithHistory
)

$ErrorActionPreference = "Continue"

# Colors
$HeaderColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"

# Paths
$HubPath = ".qwen\skills\meta-systems-hub"
$CodeHealthPath = "$HubPath\modules\code-health"
$LogsPath = "$CodeHealthPath\reports"
$HistoryPath = "$LogsPath\analysis-history.json"

# Ensure logs directory exists
if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║         Code Analysis with Context                        ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# Run flutter analyze
Write-Host "Running flutter analyze..." -ForegroundColor $InfoColor
$analyzeOutput = & flutter analyze 2>&1 | Out-String
$analyzeExitCode = $LASTEXITCODE

# Parse output
$lines = $analyzeOutput -split "`n"
$issues = @()

foreach ($line in $lines) {
    if ($line -match "(error|warning|info):.*?(line \d+, column \d+)") {
        $issues += @{
            Type = $matches[1]
            Message = $line -replace ".*?(error|warning|info):", ""
            Location = $matches[2]
            File = ($line -split ":")[0]
        }
    }
}

# Count by type
$errorCount = ($issues | Where-Object { $_.Type -eq "error" }).Count
$warningCount = ($issues | Where-Object { $_.Type -eq "warning" }).Count
$infoCount = ($issues | Where-Object { $_.Type -eq "info" }).Count

# Load history if exists
$history = @()
if (Test-Path $HistoryPath) {
    $history = Get-Content $HistoryPath -Raw | ConvertFrom-Json
}

# Create analysis result
$result = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ExitCode = $analyzeExitCode
    TotalIssues = $issues.Count
    Errors = $errorCount
    Warnings = $warningCount
    Infos = $infoCount
    Issues = $issues
    FilesAnalyzed = ($lines | Where-Object { $_ -match "\.dart" }).Count
}

# Compare with history if requested
if ($CompareWithHistory -and $history.Count -gt 0) {
    $lastAnalysis = $history | Sort-Object -Property Timestamp -Descending | Select-Object -First 1
    
    $result | Add-Member -NotePropertyName "Comparison" -NotePropertyValue @{
        PreviousTotal = $lastAnalysis.TotalIssues
        PreviousErrors = $lastAnalysis.Errors
        PreviousWarnings = $lastAnalysis.Warnings
        ErrorChange = $errorCount - $lastAnalysis.Errors
        WarningChange = $warningCount - $lastAnalysis.Warnings
        Trend = if ($errorCount -lt $lastAnalysis.Errors) { "Improving" } elseif ($errorCount -gt $lastAnalysis.Errors) { "Worsening" } else { "Stable" }
    }
}

# Save to history
$history += $result
if ($history.Count -gt 100) {
    $history = $history | Select-Object -Last 50  # Keep last 50 analyses
}
$result | ConvertTo-Json -Depth 5 | Out-File -FilePath $HistoryPath -Encoding utf8

# Display results
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Analysis Results" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

Write-Host "  Files Analyzed:  $($result.FilesAnalyzed)" -ForegroundColor $InfoColor
Write-Host "  Total Issues:    $($result.TotalIssues)" -ForegroundColor $(if($result.TotalIssues -eq 0){$SuccessColor}else{$WarningColor})
Write-Host ""

Write-Host "  Errors:   $errorCount" -ForegroundColor $(if($errorCount -eq 0){$SuccessColor}else{$ErrorColor})
Write-Host "  Warnings: $warningCount" -ForegroundColor $(if($warningCount -eq 0){$SuccessColor}else{$WarningColor})
Write-Host "  Info:     $infoCount" -ForegroundColor $InfoColor

Write-Host ""

# Show comparison if available
if ($result.Comparison) {
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Comparison with Previous Analysis" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Previous Errors:   $($result.Comparison.PreviousErrors)" -ForegroundColor $InfoColor
    Write-Host "  Current Errors:    $errorCount" -ForegroundColor $(if($errorCount -lt $result.Comparison.PreviousErrors){$SuccessColor}elseif($errorCount -gt $result.Comparison.PreviousErrors){$ErrorColor}else{$InfoColor})
    Write-Host "  Change:            $($result.Comparison.ErrorChange)" -ForegroundColor $(if($result.Comparison.ErrorChange -lt 0){$SuccessColor}elseif($result.Comparison.ErrorChange -gt 0){$ErrorColor}else{$InfoColor})
    Write-Host ""
    
    Write-Host "  Trend: $($result.Comparison.Trend)" -ForegroundColor $(if($result.Comparison.Trend -eq "Improving"){$SuccessColor}elseif($result.Comparison.Trend -eq "Worsening"){$ErrorColor}else{$InfoColor})
    Write-Host ""
}

# Show top issues
if ($issues.Count -gt 0) {
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Top Issues" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    $issues | Select-Object -First 10 | ForEach-Object {
        $color = switch ($_.Type) {
            "error" { $ErrorColor }
            "warning" { $WarningColor }
            default { $InfoColor }
        }
        
        Write-Host "  [$($_.Type.ToUpper())] $($_.File)" -ForegroundColor $color
        Write-Host "    $($_.Message)" -ForegroundColor $InfoColor
        Write-Host ""
    }
    
    if ($issues.Count -gt 10) {
        Write-Host "  ... and $($issues.Count - 10) more issues" -ForegroundColor $InfoColor
        Write-Host ""
    }
}

# Recommendations
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Recommendations" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

if ($errorCount -gt 0) {
    Write-Host "  ⚠ Fix $errorCount errors before committing" -ForegroundColor $ErrorColor
}

if ($warningCount -gt 5) {
    Write-Host "  ⚠ Review $warningCount warnings" -ForegroundColor $WarningColor
}

if ($errorCount -eq 0 -and $warningCount -eq 0) {
    Write-Host "  ✓ Code is clean! No issues found" -ForegroundColor $SuccessColor
}

Write-Host ""
Write-Host "  Run auto-fix: .\.qwen\skills\meta-systems-hub\modules\code-health\scripts\auto-fix-safe.ps1" -ForegroundColor $InfoColor
Write-Host ""

# Save to file if requested
if ($OutputPath) {
    $result | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor
}

# JSON output if requested
if ($Json) {
    $result | ConvertTo-Json -Depth 5
}

# Return result
return $result
