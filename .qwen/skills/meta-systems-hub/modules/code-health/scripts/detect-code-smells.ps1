# Detect Code Smells
# Identifies code smells and architectural issues

param(
    [switch]$Full,
    [switch]$Json,
    [string]$OutputPath,
    [int]$LongMethodThreshold = 50,
    [int]$GodClassThreshold = 300,
    [int]$HighCouplingThreshold = 10,
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
    Write-Host "║         Code Smell Detection                              ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Track smells
$Smells = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalSmells = 0
    ByType = @{
        LongMethod = 0
        GodClass = 0
        LongParameterList = 0
        DuplicateCode = 0
        FeatureEnvy = 0
        DataClass = 0
    }
    Issues = @()
}

if (-not $Silent) { Write-Host "Scanning for code smells..." -ForegroundColor $InfoColor }

# Scan Dart files
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-Object -First 100
$filesScanned = 0

foreach ($file in $dartFiles) {
    $filesScanned++
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    $lines = Get-Content $file.FullName -ErrorAction SilentlyContinue
    
    if (-not $content -or -not $lines) { continue }
    
    # 1. Long Method Detection
    $methodPattern = "(?:void|\w+\s+\w+)\s+\w+\s*\([^)]*\)\s*(?:async)?\s*\{"
    $methods = [regex]::Matches($content, $methodPattern)
    
    foreach ($method in $methods) {
        $methodStart = $method.Index
        $braceCount = 0
        $methodEnd = $methodStart
        $inMethod = $false
        
        for ($i = $methodStart; $i -lt $content.Length; $i++) {
            if ($content[$i] -eq '{') {
                $braceCount++
                $inMethod = $true
            } elseif ($content[$i] -eq '}') {
                $braceCount--
                if ($inMethod -and $braceCount -eq 0) {
                    $methodEnd = $i
                    break
                }
            }
        }
        
        if ($methodEnd -gt $methodStart) {
            $methodContent = $content.Substring($methodStart, $methodEnd - $methodStart)
            $methodLines = ($methodContent -split "`n").Count
            
            if ($methodLines -gt $LongMethodThreshold) {
                $lineNumber = ($content.Substring(0, $methodStart) -split "`n").Count
                
                $Smells.Issues += @{
                    File = $file.FullName
                    Line = $lineNumber
                    Type = "LongMethod"
                    Description = "Method has $methodLines lines (threshold: $LongMethodThreshold)"
                    Severity = $(if($methodLines -gt 100){"High"}elseif($methodLines -gt 75){"Medium"}else{"Low"})
                    Details = "$methodLines lines"
                }
                
                $Smells.TotalSmells++
                $Smells.ByType.LongMethod++
            }
        }
    }
    
    # 2. God Class Detection
    $classPattern = "class\s+\w+"
    $classes = [regex]::Matches($content, $classPattern)
    
    foreach ($class in $classes) {
        $classStart = $class.Index
        $braceCount = 0
        $classEnd = $classStart
        $inClass = $false
        
        for ($i = $classStart; $i -lt $content.Length; $i++) {
            if ($content[$i] -eq '{') {
                $braceCount++
                $inClass = $true
            } elseif ($content[$i] -eq '}') {
                $braceCount--
                if ($inClass -and $braceCount -eq 0) {
                    $classEnd = $i
                    break
                }
            }
        }
        
        if ($classEnd -gt $classStart) {
            $classContent = $content.Substring($classStart, $classEnd - $classStart)
            $classLines = ($classContent -split "`n").Count
            
            if ($classLines -gt $GodClassThreshold) {
                $lineNumber = ($content.Substring(0, $classStart) -split "`n").Count
                
                $Smells.Issues += @{
                    File = $file.FullName
                    Line = $lineNumber
                    Type = "GodClass"
                    Description = "Class has $classLines lines (threshold: $GodClassThreshold)"
                    Severity = $(if($classLines -gt 500){"High"}elseif($classLines -gt 400){"Medium"}else{"Low"})
                    Details = "$classLines lines"
                }
                
                $Smells.TotalSmells++
                $Smells.ByType.GodClass++
            }
        }
    }
    
    # 3. Long Parameter List
    $longParamPattern = "\w+\s+\w+\s*\(([^)]{100,})\)"
    $longParams = [regex]::Matches($content, $longParamPattern)
    
    foreach ($match in $longParams) {
        $paramCount = ($match.Groups[1].Value -split ",").Count
        
        if ($paramCount -gt 5) {
            $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
            
            $Smells.Issues += @{
                File = $file.FullName
                Line = $lineNumber
                Type = "LongParameterList"
                Description = "Method has $paramCount parameters (threshold: 5)"
                Severity = $(if($paramCount -gt 10){"High"}elseif($paramCount -gt 7){"Medium"}else{"Low"})
                Details = "$paramCount parameters"
            }
            
            $Smells.TotalSmells++
            $Smells.ByType.LongParameterList++
        }
    }
    
    # 4. Data Class (only getters/setters)
    $classMatches = [regex]::Matches($content, "class\s+(\w+)\s*{([^}]+)}")
    foreach ($classMatch in $classMatches) {
        $className = $classMatch.Groups[1].Value
        $classBody = $classMatch.Groups[2].Value
        
        # Check if only has fields and getters/setters
        $hasMethods = $classBody -match "(void|\w+\s+\w+)\s*\([^)]*\)\s*{"
        $hasOnlyFields = -not $hasMethods
        
        if ($hasOnlyFields -and ($classBody -split "`n").Count -gt 5) {
            $lineNumber = ($content.Substring(0, $classMatch.Index) -split "`n").Count
            
            $Smells.Issues += @{
                File = $file.FullName
                Line = $lineNumber
                Type = "DataClass"
                Description = "Class '$className' appears to be a data class (only fields)"
                Severity = "Low"
                Details = "Consider adding behavior"
            }
            
            $Smells.TotalSmells++
            $Smells.ByType.DataClass++
        }
    }
}

# Display results
if (-not $Silent) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Code Smell Detection Results" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host "  Files Scanned: $filesScanned" -ForegroundColor $InfoColor
    Write-Host "  Total Smells: $($Smells.TotalSmells)" -ForegroundColor $(if($Smells.TotalSmells -eq 0){$SuccessColor}elseif($Smells.TotalSmells -lt 10){$WarningColor}else{$ErrorColor})
    Write-Host ""
    
    # By type
    Write-Host "  By Type:" -ForegroundColor $HeaderColor
    Write-Host ""
    
    foreach ($type in $Smells.ByType.Keys) {
        $count = $Smells.ByType[$type]
        $color = switch ($count) {
            0 { $SuccessColor }
            { $_ -lt 5 } { $InfoColor }
            { $_ -lt 10 } { $WarningColor }
            default { $ErrorColor }
        }
        
        Write-Host "    $type`: $count" -ForegroundColor $color
    }
    
    Write-Host ""
    
    # Show top issues
    if ($Smells.Issues.Count -gt 0) {
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
        Write-Host "  Top Code Smells" -ForegroundColor $HeaderColor
        Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
        Write-Host ""
        
        $Smells.Issues | Sort-Object -Property Severity -Descending | Select-Object -First 10 | ForEach-Object {
            $color = switch ($_.Severity) {
                "High" { $ErrorColor }
                "Medium" { $WarningColor }
                default { $InfoColor }
            }
            
            Write-Host "  [$($_.Type)] $($_.File)" -ForegroundColor $color
            Write-Host "    Line $($_.Line): $($_.Description)" -ForegroundColor $InfoColor
            Write-Host "    Details: $($_.Details)" -ForegroundColor $GrayColor
            Write-Host ""
        }
    }
    
    # Recommendations
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  Recommendations" -ForegroundColor $HeaderColor
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
    
    if ($Smells.ByType.LongMethod -gt 0) {
        Write-Host "  ⚠ Refactor $($Smells.ByType.LongMethod) long methods (extract methods)" -ForegroundColor $WarningColor
    }
    
    if ($Smells.ByType.GodClass -gt 0) {
        Write-Host "  ⚠ Refactor $($Smells.ByType.GodClass) god classes (split into smaller classes)" -ForegroundColor $WarningColor
    }
    
    if ($Smells.ByType.LongParameterList -gt 0) {
        Write-Host "  ⚠ Refactor $($Smells.ByType.LongParameterList) methods with long parameter lists (use parameter objects)" -ForegroundColor $WarningColor
    }
    
    if ($Smells.ByType.DataClass -gt 0) {
        Write-Host "  ℹ Consider adding behavior to $($Smells.ByType.DataClass) data classes" -ForegroundColor $InfoColor
    }
    
    if ($Smells.TotalSmells -eq 0) {
        Write-Host "  ✓ No code smells detected!" -ForegroundColor $SuccessColor
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Code Smell Detection Complete                     ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

# Save results
$Smells | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\code-smells-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

if ($OutputPath) {
    $Smells | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
    if (-not $Silent) { Write-Host "  Results saved to: $OutputPath" -ForegroundColor $InfoColor }
}

if ($Json) {
    $Smells | ConvertTo-Json -Depth 5
}

return $Smells
