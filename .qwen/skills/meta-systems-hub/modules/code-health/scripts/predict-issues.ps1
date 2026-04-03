# Predict Issues Before They Happen
# Analyzes code patterns to predict potential issues

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
$CodeHealthPath = ".qwen\skills\meta-systems-hub\modules\code-health"
$LogsPath = "$CodeHealthPath\reports"

# Ensure logs directory exists
if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Predictive Issue Detection                        ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Track predictions
$Predictions = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalPredictions = 0
    ByCategory = @{
        NullSafety = 0
        Async = 0
        StateManagement = 0
        ResourceLeaks = 0
        Performance = 0
        Security = 0
    }
    Issues = @()
}

# Pattern definitions
$Patterns = @{
    NullSafety = @(
        @{ Pattern = "!\.([^=])"; Description = "Potential null dereference with !"; Severity = "High" },
        @{ Pattern = "as\s+\w+\?"; Description = "Type cast with nullable"; Severity = "Medium" },
        @{ Pattern = "late\s+\w+"; Description = "Late initialization - ensure it's set before use"; Severity = "Medium" }
    )
    Async = @(
        @{ Pattern = "Future<\w+>\s+\w+\s*\([^)]*\)\s*(?!\{)"; Description = "Future-returning function without async/await"; Severity = "Medium" },
        @{ Pattern = "\.then\([^)]*\)(?!\.catchError)"; Description = ".then() without .catchError"; Severity = "High" },
        @{ Pattern = "async\s*(?![\s\S]*await)"; Description = "async without await"; Severity = "Low" }
    )
    StateManagement = @(
        @{ Pattern = "setState\s*\([^)]*\)\s*{"; Description = "setState - check if mounted"; Severity = "Medium" },
        @{ Pattern = "if\s*\(!mounted\)"; Description = "Mounted check detected (good!)"; Severity = "Info" },
        @{ Pattern = "Controller\s*=\s*"; Description = "Controller initialization - ensure dispose"; Severity = "Medium" }
    )
    ResourceLeaks = @(
        @{ Pattern = "StreamController<\w+>\s*\("; Description = "StreamController - ensure close"; Severity = "High" },
        @{ Pattern = "StreamSubscription<\w+>\s*="; Description = "StreamSubscription - ensure cancel"; Severity = "High" },
        @{ Pattern = "Timer\.(periodic|singleShot)"; Description = "Timer - ensure cancel"; Severity = "Medium" },
        @{ Pattern = "AnimationController\s*\("; Description = "AnimationController - ensure dispose"; Severity = "Medium" }
    )
    Performance = @(
        @{ Pattern = "setState\s*\([^)]*setState"; Description = "Nested setState calls"; Severity = "Medium" },
        @{ Pattern = "ListView\.builder\s*\([^)]*items:\s*\d+"; Description = "ListView.builder with small items - consider ListView"; Severity = "Low" },
        @{ Pattern = "for\s*\([^)]*\)\s*{[^}]*setState"; Description = "setState in loop"; Severity = "High" }
    )
    Security = @(
        @{ Pattern = "print\s*\([^)]*(password|token|secret|key)"; Description = "Potential sensitive data in print"; Severity = "Critical" },
        @{ Pattern = "SharedPreferences.*setString\s*\([^)]*(password|token|secret)"; Description = "Plaintext sensitive data storage"; Severity = "Critical" },
        @{ Pattern = "http\.(get|post)\s*\([^)]*http://"; Description = "HTTP (not HTTPS) request"; Severity = "High" }
    )
}

# Scan Dart files
if (-not $Silent) { Write-Host "Scanning Dart files for predictive patterns..." -ForegroundColor $InfoColor }

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-Object -First 100
$filesScanned = 0

foreach ($file in $dartFiles) {
    $filesScanned++
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) { continue }
    
    foreach ($category in $Patterns.Keys) {
        foreach ($pattern in $Patterns[$category]) {
            $matches = [regex]::Matches($content, $pattern.Pattern)
            
            foreach ($match in $matches) {
                $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
                
                $Predictions.Issues += @{
                    File = $file.FullName
                    Line = $lineNumber
                    Category = $category
                    Pattern = $pattern.Pattern
                    Description = $pattern.Description
                    Severity = $pattern.Severity
                    Match = $match.Value.Substring(0, [Math]::Min(50, $match.Value.Length))
                }
                
                $Predictions.TotalPredictions++
                $Predictions.ByCategory[$category]++
            }
        }
    }
}

# Display results
if (-not $Silent) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Predictive Analysis Results" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Files Scanned: $filesScanned" -ForegroundColor $InfoColor
    Write-Host "  Total Predictions: $($Predictions.TotalPredictions)" -ForegroundColor $(if($Predictions.TotalPredictions -eq 0){$SuccessColor}elseif($Predictions.TotalPredictions -lt 10){$WarningColor}else{$ErrorColor})
    Write-Host ""
    
    # By category
    Write-Host "  By Category:" -ForegroundColor $HeaderColor
    Write-Host ""
    
    foreach ($category in $Predictions.ByCategory.Keys) {
        $count = $Predictions.ByCategory[$category]
        $color = switch ($count) {
            0 { $SuccessColor }
            { $_ -lt 5 } { $InfoColor }
            { $_ -lt 10 } { $WarningColor }
            default { $ErrorColor }
        }
        
        Write-Host "    $category`: $count" -ForegroundColor $color
    }
    
    Write-Host ""
    
    # Show critical/high severity issues
    $criticalIssues = $Predictions.Issues | Where-Object { $_.Severity -eq "Critical" -or $_.Severity -eq "High" }
    
    if ($criticalIssues.Count -gt 0) {
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host "  Critical/High Severity Issues" -ForegroundColor $ErrorColor
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $ErrorColor
        Write-Host ""
        
        $criticalIssues | Select-Object -First 10 | ForEach-Object {
            Write-Host "  [$($_.Severity)] $($_.File)" -ForegroundColor $(if($_.Severity -eq "Critical"){$ErrorColor}else{$WarningColor})
            Write-Host "    Line $($_.Line): $($_.Description)" -ForegroundColor $InfoColor
            Write-Host "    Match: `"$($_.Match)`"" -ForegroundColor $GrayColor
            Write-Host ""
        }
        
        if ($criticalIssues.Count -gt 10) {
            Write-Host "  ... and $($criticalIssues.Count - 10) more issues" -ForegroundColor $InfoColor
            Write-Host ""
        }
    }
    
    # Recommendations
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Recommendations" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    if ($Predictions.ByCategory.NullSafety -gt 0) {
        Write-Host "  ⚠ Review $($Predictions.ByCategory.NullSafety) null safety patterns" -ForegroundColor $WarningColor
    }
    
    if ($Predictions.ByCategory.Async -gt 0) {
        Write-Host "  ⚠ Review $($Predictions.ByCategory.Async) async/await patterns" -ForegroundColor $WarningColor
    }
    
    if ($Predictions.ByCategory.StateManagement -gt 0) {
        Write-Host "  ⚠ Review $($Predictions.ByCategory.StateManagement) state management patterns" -ForegroundColor $WarningColor
    }
    
    if ($Predictions.ByCategory.ResourceLeaks -gt 0) {
        Write-Host "  ⚠ Review $($Predictions.ByCategory.ResourceLeaks) potential resource leaks" -ForegroundColor $WarningColor
    }
    
    if ($Predictions.ByCategory.Security -gt 0) {
        Write-Host "  ⚠ CRITICAL: Review $($Predictions.ByCategory.Security) security issues" -ForegroundColor $ErrorColor
    }
    
    if ($Predictions.TotalPredictions -eq 0) {
        Write-Host "  ✓ No predictive issues found!" -ForegroundColor $SuccessColor
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Predictive Analysis Complete                      ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Save results
$Predictions | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\predictions-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Predictions | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    if (-not $Silent) { Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor }
}

if ($Json) {
    $Predictions | ConvertTo-Json -Depth 5
}

return $Predictions
