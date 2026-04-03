# Generate Unit Tests
# Automatically generates unit tests for services and utilities

param(
    [string]$TargetFile,
    [switch]$All,
    [switch]$Services,
    [switch]$Utils,
    [switch]$Models,
    [switch]$DryRun,
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
$TestPath = ".qwen\skills\meta-systems-hub\modules\test-coverage"
$LogsPath = "$TestPath\reports"

if (-not (Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
    Write-Host "║         Unit Test Generator                               ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    FilesGenerated = 0
    FilesSkipped = 0
    TestsGenerated = @()
    Errors = @()
}

# Test template
$TestTemplate = @"
import 'package:flutter_test/flutter_test.dart';

// TODO: Import the file being tested
// import 'package:steps_recovery_flutter/{FILE_PATH}';

void main() {
  group('{CLASS_NAME} Tests', () {
    
    // TODO: Set up test fixtures
    // late {CLASS_NAME} {variableName};
    
    // setUp(() {
    //   {variableName} = {CLASS_NAME}();
    // });
    
    test('should create instance', () {
      // TODO: Implement test
      expect(true, isTrue);
    });
    
    // TODO: Add more tests for each method
    // test('should {EXPECTED_BEHAVIOR}', () {
    //   // Arrange
    //   
    //   // Act
    //   
    //   // Assert
    // });
    
  });
}
"@

function Get-ClassName {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $classMatch = [regex]::Match($content, 'class\s+(\w+)')
    
    if ($classMatch.Success) {
        return $classMatch.Groups[1].Value
    } else {
        return [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    }
}

function Generate-TestFile {
    param(
        [string]$SourceFile,
        [string]$TestPath
    )
    
    $className = Get-ClassName -FilePath $SourceFile
    $sourceFileName = [System.IO.Path]::GetFileName($SourceFile)
    $testFileName = $sourceFileName -replace ".dart", "_test.dart"
    
    # Determine test directory
    $testDir = ""
    if ($SourceFile -match "lib[\\/]core[\\/]services[\\/]") {
        $testDir = "test/core/services/"
    } elseif ($SourceFile -match "lib[\\/]core[\\/]utils[\\/]") {
        $testDir = "test/core/utils/"
    } elseif ($SourceFile -match "lib[\\/]core[\\/]models[\\/]") {
        $testDir = "test/core/models/"
    } elseif ($SourceFile -match "lib[\\/]features[\\/]([^\\]+)[\\/]") {
        $feature = $matches[1]
        $testDir = "test/features/$feature/"
    } else {
        $testDir = "test/"
    }
    
    # Create directory if needed
    if (-not (Test-Path $testDir)) {
        New-Item -ItemType Directory -Force -Path $testDir | Out-Null
    }
    
    $testFilePath = "$testDir$testFileName"
    
    # Check if test already exists
    if (Test-Path $testFilePath) {
        Write-Host "  ⚠ Test already exists: $testFileName" -ForegroundColor $WarningColor
        return $false
    }
    
    # Generate test content
    $relativePath = $SourceFile -replace [regex]::Escape((Get-Location).Path), "" -replace "\\", "/"
    $testContent = $TestTemplate -replace "{FILE_PATH}", $relativePath -replace "{CLASS_NAME}", $className
    
    if (-not $DryRun) {
        $testContent | Out-File -FilePath $testFilePath -Encoding utf8
        Write-Host "  ✓ Generated: $testFileName" -ForegroundColor $SuccessColor
        return $true
    } else {
        Write-Host "  ℹ Would generate: $testFileName" -ForegroundColor $InfoColor
        return $true
    }
}

# Find files to test
$filesToTest = @()

if ($TargetFile) {
    # Test specific file
    if (Test-Path $TargetFile) {
        $filesToTest += $TargetFile
    } else {
        Write-Host "  ✗ File not found: $TargetFile" -ForegroundColor $ErrorColor
        $Results.Errors += "File not found: $TargetFile"
    }
} elseif ($All) {
    # Test all files
    Write-Host "Finding all services, utils, and models..." -ForegroundColor $InfoColor
    
    $filesToTest += Get-ChildItem -Path "lib/core/services" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    $filesToTest += Get-ChildItem -Path "lib/core/utils" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    $filesToTest += Get-ChildItem -Path "lib/core/models" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
} elseif ($Services) {
    # Test services only
    Write-Host "Finding services..." -ForegroundColor $InfoColor
    $filesToTest += Get-ChildItem -Path "lib/core/services" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
} elseif ($Utils) {
    # Test utils only
    Write-Host "Finding utilities..." -ForegroundColor $InfoColor
    $filesToTest += Get-ChildItem -Path "lib/core/utils" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
} elseif ($Models) {
    # Test models only
    Write-Host "Finding models..." -ForegroundColor $InfoColor
    $filesToTest += Get-ChildItem -Path "lib/core/models" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
} else {
    # Default: Find untested services
    Write-Host "Finding untested services..." -ForegroundColor $InfoColor
    
    $serviceFiles = Get-ChildItem -Path "lib/core/services" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue
    foreach ($file in $serviceFiles) {
        $testFileName = $file.Name -replace ".dart", "_test.dart"
        $testPath = "test/core/services/$testFileName"
        
        if (-not (Test-Path $testPath)) {
            $filesToTest += $file.FullName
        }
    }
}

Write-Host ""
Write-Host "Generating tests for $($filesToTest.Count) files..." -ForegroundColor $InfoColor
Write-Host ""

# Generate tests
foreach ($file in $filesToTest) {
    $generated = Generate-TestFile -SourceFile $file -TestPath "test/"
    
    if ($generated) {
        $Results.FilesGenerated++
        $Results.TestsGenerated += $file
    } else {
        $Results.FilesSkipped++
    }
}

# Summary
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Test Generation Summary" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

Write-Host "  Files Generated: $($Results.FilesGenerated)" -ForegroundColor $(if($Results.FilesGenerated -gt 0){$SuccessColor}else{$InfoColor})
Write-Host "  Files Skipped:   $($Results.FilesSkipped)" -ForegroundColor $(if($Results.FilesSkipped -eq 0){$SuccessColor}else{$WarningColor})
Write-Host ""

if ($Results.Errors.Count -gt 0) {
    Write-Host "  Errors:" -ForegroundColor $ErrorColor
    $Results.Errors | ForEach-Object {
        Write-Host "    - $_" -ForegroundColor $ErrorColor
    }
    Write-Host ""
}

Write-Host "Next Steps:" -ForegroundColor $InfoColor
Write-Host "  1. Review generated tests" -ForegroundColor $InfoColor
Write-Host "  2. Implement test logic (look for TODO comments)" -ForegroundColor $InfoColor
Write-Host "  3. Run tests: flutter test" -ForegroundColor $InfoColor
Write-Host ""

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║         Test Generation Complete                          ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\test-generation-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

return $Results
