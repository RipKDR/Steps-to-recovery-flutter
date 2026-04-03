# Generate Widget Tests
# Automatically generates widget tests for screens

param(
    [string]$Screen,
    [switch]$All,
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
    Write-Host "║         Widget Test Generator                             ║" -ForegroundColor $HeaderColor
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
    Write-Host ""
}

$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ScreensGenerated = 0
    ScreensSkipped = 0
    TestsGenerated = @()
}

# Widget test template
$WidgetTestTemplate = @"
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/{SCREEN_IMPORT}';

// TODO: Import mocks if needed
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';

// TODO: Generate mocks
// @GenerateMocks([ServiceName])
// void main() {

void main() {
  group('{SCREEN_NAME} Widget Tests', () {
    
    testWidgets('should render without crashing', (WidgetTester tester) async {
      // TODO: Set up test dependencies
      // final mockService = MockService();
      
      await tester.pumpWidget(
        MaterialApp(
          home: {SCREEN_NAME}(),
          // TODO: Add required providers
          // providers: [
          //   Provider.value(value: mockService),
          // ],
        ),
      );
      
      // TODO: Add widget tests
      expect(find.byType({SCREEN_NAME}), findsOneWidget);
      
      // Example: Test for specific widgets
      // expect(find.text('Expected Text'), findsOneWidget);
      // expect(find.byType(ListView), findsOneWidget);
    });
    
    // TODO: Add more widget tests
    // testWidgets('should {EXPECTED_BEHAVIOR}', (WidgetTester tester) async {
    //   // Arrange
    //   
    //   // Act
    //   await tester.pumpWidget(...);
    //   
    //   // Assert
    //   expect(...);
    // });
    
  });
}
"@

function Get-ScreenName {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $classMatch = [regex]::Match($content, 'class\s+(\w+Screen)')
    
    if ($classMatch.Success) {
        return $classMatch.Groups[1].Value
    } else {
        return [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    }
}

function Generate-WidgetTest {
    param(
        [string]$ScreenFile
    )
    
    $screenName = Get-ScreenName -FilePath $ScreenFile
    $screenFileName = [System.IO.Path]::GetFileName($ScreenFile)
    $testFileName = $screenFileName -replace ".dart", "_test.dart"
    
    # Determine feature from path
    $feature = ""
    if ($ScreenFile -match "lib[\\/]features[\\/]([^\\]+)[\\/]") {
        $feature = $matches[1]
    }
    
    $testDir = if ($feature) { "test/features/$feature/" } else { "test/widgets/" }
    
    # Create directory if needed
    if (-not (Test-Path $testDir)) {
        New-Item -ItemType Directory -Force -Path $testDir | Out-Null
    }
    
    $testFilePath = "$testDir$testFileName"
    
    # Check if test already exists
    if (Test-Path $testFilePath) {
        Write-Host "  ⚠ Test already exists: $screenName" -ForegroundColor $WarningColor
        return $false
    }
    
    # Generate import path
    $relativePath = $ScreenFile -replace [regex]::Escape((Get-Location).Path + "\"), "" -replace "\\", "/"
    
    # Generate test content
    $testContent = $WidgetTestTemplate -replace "{SCREEN_IMPORT}", $relativePath -replace "{SCREEN_NAME}", $screenName
    
    if (-not $DryRun) {
        $testContent | Out-File -FilePath $testFilePath -Encoding utf8
        Write-Host "  ✓ Generated: $screenName test" -ForegroundColor $SuccessColor
        return $true
    } else {
        Write-Host "  ℹ Would generate: $screenName test" -ForegroundColor $InfoColor
        return $true
    }
}

# Find screens to test
$screensToTest = @()

if ($Screen) {
    # Test specific screen
    $screenFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*$Screen*.dart" -ErrorAction SilentlyContinue
    $screensToTest += $screenFiles | Where-Object { $_.Name -match "screen.dart" } | Select-Object -ExpandProperty FullName
} elseif ($All) {
    # Test all screens
    Write-Host "Finding all screens..." -ForegroundColor $InfoColor
    $screensToTest += Get-ChildItem -Path "lib/features" -Recurse -Filter "*screen.dart" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
} else {
    # Find untested screens
    Write-Host "Finding untested screens..." -ForegroundColor $InfoColor
    
    $screenFiles = Get-ChildItem -Path "lib/features" -Recurse -Filter "*screen.dart" -ErrorAction SilentlyContinue
    foreach ($file in $screenFiles) {
        $testFileName = $file.Name -replace ".dart", "_test.dart"
        $feature = ($file.FullName -split "[\\/]features[\\/]")[1] -split "[\\/]")[0]
        $testPath = "test/features/$feature/$testFileName"
        
        if (-not (Test-Path $testPath)) {
            $screensToTest += $file.FullName
        }
    }
}

Write-Host ""
Write-Host "Generating widget tests for $($screensToTest.Count) screens..." -ForegroundColor $InfoColor
Write-Host ""

# Generate tests
foreach ($screen in $screensToTest) {
    $generated = Generate-WidgetTest -ScreenFile $screen
    
    if ($generated) {
        $Results.ScreensGenerated++
        $Results.TestsGenerated += $screen
    } else {
        $Results.ScreensSkipped++
    }
}

# Summary
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  Widget Test Generation Summary" -ForegroundColor $HeaderColor
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

Write-Host "  Screens Generated: $($Results.ScreensGenerated)" -ForegroundColor $(if($Results.ScreensGenerated -gt 0){$SuccessColor}else{$InfoColor})
Write-Host "  Screens Skipped:   $($Results.ScreensSkipped)" -ForegroundColor $(if($Results.ScreensSkipped -eq 0){$SuccessColor}else{$WarningColor})
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor $InfoColor
Write-Host "  1. Review generated tests" -ForegroundColor $InfoColor
Write-Host "  2. Implement test logic (look for TODO comments)" -ForegroundColor $InfoColor
Write-Host "  3. Add mock imports and setup" -ForegroundColor $InfoColor
Write-Host "  4. Run tests: flutter test" -ForegroundColor $InfoColor
Write-Host ""

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║         Widget Test Generation Complete                   ║" -ForegroundColor $HeaderColor
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$LogsPath\widget-test-generation-$(Get-Date -Format 'yyyy-MM-dd').json" -Encoding utf8

return $Results
