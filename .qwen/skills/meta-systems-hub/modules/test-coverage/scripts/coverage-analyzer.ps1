# Coverage Analyzer
# Analyzes test coverage and identifies untested code

param(
    [switch]$Full,
    [switch]$Json,
    [string]$OutputPath,
    [switch]$Silent,
    [int]$MinCoverage = 80
)

$ErrorActionPreference = "Continue"

# Colors
$HeaderColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"
$InfoColor = "Gray"

# Paths
$TestPath = ".qwen\skills\meta-systems-hub\modules\test-coverage"
$LogsPath = "$TestPath\reports"

if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Test Coverage Analyzer                            ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Coverage = 0
    TargetCoverage = $MinCoverage
    Status = "Unknown"
    FilesAnalyzed = 0
    FilesTested = 0
    FilesUntested = @()
    FilesPartial = @()
    ByFeature = @{}
    Recommendations = @()
}

Write-Host "Analyzing test coverage..." -ForegroundColor $InfoColor
Write-Host ""

# Try to get coverage from lcov.info
$lcovPath = "coverage/lcov.info"
$hasCoverage = Test-Path $lcovPath

if ($hasCoverage) {
    Write-Host "Found coverage data: $lcovPath" -ForegroundColor $SuccessColor
    
    $lcovContent = Get-Content $lcovPath -Raw
    $lines = $lcovContent -split "`n"
    
    $totalLines = 0
    $hitLines = 0
    $fileCoverage = @{}
    
    $currentFile = ""
    foreach ($line in $lines) {
        if ($line -match "^SF:(.+)") {
            $currentFile = $matches[1]
            $fileCoverage[$currentFile] = @{ Total = 0; Hit = 0 }
        } elseif ($line -match "^DA:(\d+),(\d+)") {
            $lineNum = $matches[1]
            $hitCount = [int]$matches[2]
            
            if ($currentFile -ne "") {
                $fileCoverage[$currentFile].Total++
                $totalLines++
                
                if ($hitCount -gt 0) {
                    $fileCoverage[$currentFile].Hit++
                    $hitLines++
                }
            }
        }
    }
    
    $coverage = [math]::Round(($hitLines / $totalLines) * 100, 1)
    $Results.Coverage = $coverage
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Coverage Summary" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Total Lines:     $totalLines" -ForegroundColor $InfoColor
    Write-Host "  Covered Lines:   $hitLines" -ForegroundColor $SuccessColor
    Write-Host "  Uncovered Lines: $($totalLines - $hitLines)" -ForegroundColor $(if($totalLines -eq $hitLines){$SuccessColor}else{$WarningColor})
    Write-Host ""
    
    Write-Host "  Coverage: $coverage%" -ForegroundColor $(if($coverage -ge $MinCoverage){$SuccessColor}elseif($coverage -ge 50){$WarningColor}else{$ErrorColor})
    Write-Host "  Target:   $MinCoverage%" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Analyze by feature
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Coverage by Feature" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    $features = @("home", "journal", "steps", "meetings", "profile", "crisis", "inventory", "sponsor", "gratitude", "safety_plan")
    
    foreach ($feature in $features) {
        $featureFiles = $fileCoverage.Keys | Where-Object { $_ -match "/features/$feature/" }
        $featureTotal = 0
        $featureHit = 0
        
        foreach ($file in $featureFiles) {
            $featureTotal += $fileCoverage[$file].Total
            $featureHit += $fileCoverage[$file].Hit
        }
        
        if ($featureTotal -gt 0) {
            $featureCoverage = [math]::Round(($featureHit / $featureTotal) * 100, 1)
            $Results.ByFeature[$feature] = $featureCoverage
            
            Write-Host "  $feature`: $featureCoverage%" -ForegroundColor $(if($featureCoverage -ge $MinCoverage){$SuccessColor}elseif($featureCoverage -ge 50){$WarningColor}else{$ErrorColor})
        }
    }
    
    Write-Host ""
    
    # Find untested files
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Untested Files" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    $libFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-Object -First 100
    $testFiles = Get-ChildItem -Path "test" -Recurse -Filter "*_test.dart"
    
    foreach ($libFile in $libFiles) {
        $relativePath = $libFile.FullName -replace [regex]::Escape((Get-Location).Path), "" -replace "\\", "/"
        $relativePath = $relativePath -replace "^/lib/", "lib/"
        
        $hasTest = $false
        foreach ($testFile in $testFiles) {
            $testContent = Get-Content $testFile.FullName -Raw
            if ($testContent -match [regex]::Escape($libFile.Name -replace ".dart", "")) {
                $hasTest = $true
                break
            }
        }
        
        $coverageExists = $fileCoverage.ContainsKey($relativePath)
        $fileCoverageValue = if ($coverageExists) { $fileCoverage[$relativePath].Hit / $fileCoverage[$relativePath].Total * 100 } else { 0 }
        
        if (-not $hasTest -and -not $coverageExists) {
            $Results.FilesUntested += @{
                File = $libFile.FullName
                Feature = ($libFile.FullName -split "[\\/]features[\\/]")[1] -split "[\\/]")[0]
                Lines = (Get-Content $libFile.FullName | Measure-Object -Line).Lines
            }
        } elseif ($fileCoverageValue -lt 50) {
            $Results.FilesPartial += @{
                File = $libFile.FullName
                Coverage = [math]::Round($fileCoverageValue, 1)
            }
        }
    }
    
    Write-Host "  Files with no tests: $($Results.FilesUntested.Count)" -ForegroundColor $(if($Results.FilesUntested.Count -eq 0){$SuccessColor}else{$WarningColor})
    Write-Host "  Files with <50% coverage: $($Results.FilesPartial.Count)" -ForegroundColor $(if($Results.FilesPartial.Count -eq 0){$SuccessColor}else{$WarningColor})
    Write-Host ""
    
    if ($Results.FilesUntested.Count -gt 0) {
        Write-Host "  Top 10 untested files:" -ForegroundColor $InfoColor
        Write-Host ""
        
        $Results.FilesUntested | Select-Object -First 10 | ForEach-Object {
            Write-Host "    - $($_.File)" -ForegroundColor $WarningColor
            Write-Host "      Lines: $($_.Lines)" -ForegroundColor $InfoColor
        }
        
        Write-Host ""
    }
    
} else {
    Write-Host "No coverage data found. Run tests first:" -ForegroundColor $WarningColor
    Write-Host "  flutter test --coverage" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Estimate from test files
    Write-Host "Estimating coverage from test files..." -ForegroundColor $InfoColor
    
    $testFiles = Get-ChildItem -Path "test" -Recurse -Filter "*_test.dart" | Measure-Object | Select-Object -ExpandProperty Count
    $libFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Measure-Object | Select-Object -ExpandProperty Count
    
    if ($libFiles -gt 0) {
        $estimatedCoverage = [math]::Min(85, ($testFiles / $libFiles) * 100)
        $Results.Coverage = $estimatedCoverage
        $Results.Status = "Estimated"
        
        Write-Host ""
        Write-Host "  Estimated Coverage: ~$estimatedCoverage%" -ForegroundColor $(if($estimatedCoverage -ge $MinCoverage){$SuccessColor}else{$WarningColor})
        Write-Host "  Test Files: $testFiles" -ForegroundColor $InfoColor
        Write-Host "  Library Files: $libFiles" -ForegroundColor $InfoColor
        Write-Host "  Ratio: $([math]::Round($testFiles/$libFiles*100, 1))%" -ForegroundColor $InfoColor
    }
}

# Determine status
if ($Results.Coverage -ge $MinCoverage) {
    $Results.Status = "Excellent"
} elseif ($Results.Coverage -ge 50) {
    $Results.Status = "Good"
    $Results.Recommendations += "Increase coverage to $MinCoverage%"
} else {
    $Results.Status = "Needs Work"
    $Results.Recommendations += "Critical: Coverage below 50%"
    $Results.Recommendations += "Add tests for untested files"
}

# Recommendations
if ($Results.FilesUntested.Count -gt 10) {
    $Results.Recommendations += "Generate tests for $($Results.FilesUntested.Count) untested files"
}

if ($Results.FilesPartial.Count -gt 5) {
    $Results.Recommendations += "Improve coverage for $($Results.FilesPartial.Count) partially tested files"
}

# Display summary
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Recommendations" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

if ($Results.Recommendations.Count -gt 0) {
    $Results.Recommendations | ForEach-Object {
        Write-Host "  ⚠ $_" -ForegroundColor $WarningColor
    }
} else {
    Write-Host "  ✓ Coverage is excellent! No recommendations." -ForegroundColor $SuccessColor
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║         Coverage Analysis Complete                        ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\coverage-analysis-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    if (-not $Silent) { Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor }
}

if ($Json) {
    $Results | ConvertTo-Json -Depth 5
}

return $Results
