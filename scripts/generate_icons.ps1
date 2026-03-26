# Steps to Recovery - App Icon Generation Script
# 
# This script converts SVG icons to PNG format using ImageMagick
# Prerequisites: ImageMagick must be installed
#
# Installation:
#   Windows: choco install imagemagick -y
#   Or download from: https://imagemagick.org/script/download.php

Write-Host "🎨 Steps to Recovery - App Icon Generator" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if ImageMagick is installed
try {
    $magickVersion = magick -version 2>$null
    if ($null -eq $magickVersion) {
        throw "ImageMagick not found"
    }
    Write-Host "✅ ImageMagick detected: $($magickVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ ImageMagick is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install ImageMagick:" -ForegroundColor Yellow
    Write-Host "  Option 1 (Chocolatey): choco install imagemagick -y" -ForegroundColor Gray
    Write-Host "  Option 2 (Download): https://imagemagick.org/script/download.php" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Alternatively, use the Dart script:" -ForegroundColor Yellow
    Write-Host "  dart run scripts/generate_icons.dart" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Create output directory if it doesn't exist
$outputDir = "assets\icons"
if (-not (Test-Path $outputDir)) {
    Write-Host "📁 Creating output directory: $outputDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

Write-Host ""
Write-Host "🔄 Converting SVG to PNG..." -ForegroundColor Cyan
Write-Host ""

# Convert main app icon (1024x1024)
Write-Host "  → app_icon.png (1024x1024)" -ForegroundColor Gray
magick convert -background none -resize 1024x1024 assets\icons\app_icon.svg assets\icons\app_icon.png

# Convert foreground icon (1024x1024)
Write-Host "  → app_icon_foreground.png (1024x1024)" -ForegroundColor Gray
magick convert -background none -resize 1024x1024 assets\icons\app_icon_foreground.svg assets\icons\app_icon_foreground.png

# Convert splash logo (512x512)
Write-Host "  → splash_logo.png (512x512)" -ForegroundColor Gray
magick convert -background none -resize 512x512 assets\icons\splash_logo.svg assets\icons\splash_logo.png

Write-Host ""
Write-Host "✅ Conversion complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Generated files:" -ForegroundColor Cyan
Write-Host "   - assets\icons\app_icon.png" -ForegroundColor Gray
Write-Host "   - assets\icons\app_icon_foreground.png" -ForegroundColor Gray
Write-Host "   - assets\icons\splash_logo.png" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Run: flutter pub run flutter_launcher_icons" -ForegroundColor Gray
Write-Host "   2. Run: flutter pub run flutter_native_splash:create" -ForegroundColor Gray
Write-Host ""
