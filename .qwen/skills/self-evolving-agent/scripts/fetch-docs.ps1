#Requires -Version 5.1
<#
.SYNOPSIS
    Fetches latest documentation from various sources
.DESCRIPTION
    Downloads and caches documentation from:
    - Flutter/Dart official docs
    - Pub.dev package docs
    - Qwen Code framework docs
    - Other technology docs (Supabase, Azure, Google AI)
.PARAMETER All
    Fetch from all sources
.PARAMETER Source
    Fetch from specific source (flutter, dart, pubdev, qwen, supabase, azure, googleai)
.PARAMETER Package
    Fetch docs for specific pub.dev package
.PARAMETER Force
    Force refresh even if cache is fresh
.PARAMETER DryRun
    Show what would be fetched without downloading
.EXAMPLE
    .\fetch-docs.ps1 -All
.EXAMPLE
    .\fetch-docs.ps1 -Source flutter
.EXAMPLE
    .\fetch-docs.ps1 -Package go_router
.EXAMPLE
    .\fetch-docs.ps1 -All -DryRun
#>

param(
    [switch]$All,
    [ValidateSet('flutter', 'dart', 'pubdev', 'qwen', 'supabase', 'azure', 'googleai')]
    [string]$Source,
    [string]$Package,
    [switch]$Force,
    [switch]$DryRun
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils\logger.ps1"

# Initialize
$LogPath = "$ScriptDir\..\logs\doc-fetch.log"
$DocCacheDir = "$ScriptDir\..\doc-cache"
$ProjectRoot = "$PSScriptRoot\..\..\..\.."
$PubSpecPath = "$ProjectRoot\pubspec.yaml"

Write-Log "Starting documentation fetch" $LogPath

try {
    # Determine what to fetch
    $SourcesToFetch = @()
    
    if ($All) {
        $SourcesToFetch = @('flutter', 'dart', 'pubdev', 'qwen')
    }
    elseif ($Source) {
        $SourcesToFetch = @($Source)
    }
    elseif ($Package) {
        $SourcesToFetch = @('pubdev')
    }
    else {
        Write-Log "No source specified. Use -All, -Source, or -Package" $LogPath -Level Warning
        Write-Host "No source specified. Use -All, -Source, or -Package" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Log "Fetching from sources: $($SourcesToFetch -join ', ')" $LogPath
    
    foreach ($src in $SourcesToFetch) {
        Write-Log "Processing source: $src" $LogPath
        
        switch ($src) {
            'flutter' {
                Fetch-FlutterDocs -CacheDir "$DocCacheDir\flutter" -Force:$Force -DryRun:$DryRun
            }
            'dart' {
                Fetch-DartDocs -CacheDir "$DocCacheDir\dart" -Force:$Force -DryRun:$DryRun
            }
            'pubdev' {
                if ($Package) {
                    Fetch-PubDevPackage -PackageName $Package -CacheDir "$DocCacheDir\pubdev" -Force:$Force -DryRun:$DryRun
                } else {
                    Fetch-PubDevPackages -PubSpecPath $PubSpecPath -CacheDir "$DocCacheDir\pubdev" -Force:$Force -DryRun:$DryRun
                }
            }
            'qwen' {
                Fetch-QwenDocs -CacheDir "$DocCacheDir\qwen" -Force:$Force -DryRun:$DryRun
            }
            'supabase' {
                Fetch-SupabaseDocs -CacheDir "$DocCacheDir\supabase" -Force:$Force -DryRun:$DryRun
            }
            'azure' {
                Fetch-AzureDocs -CacheDir "$DocCacheDir\azure" -Force:$Force -DryRun:$DryRun
            }
            'googleai' {
                Fetch-GoogleAIDocs -CacheDir "$DocCacheDir\googleai" -Force:$Force -DryRun:$DryRun
            }
        }
    }
    
    Write-Log "Documentation fetch complete" $LogPath
    Write-Host "`n=== Documentation Fetch Summary ===" -ForegroundColor Cyan
    Write-Host "Completed successfully" -ForegroundColor Green
}
catch {
    Write-Log "Error during doc fetch: $($_.Exception.Message)" $LogPath -Level Error
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

function Fetch-FlutterDocs {
    param(
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Host "`nFetching Flutter documentation..." -ForegroundColor Cyan
    Write-Log "Fetching Flutter docs to $CacheDir" $LogPath
    
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    
    # Check cache age
    $cacheIndex = "$CacheDir\index.json"
    if (Test-Path $cacheIndex -and -not $Force) {
        $cacheAge = (Get-Date) - (Get-Item $cacheIndex).LastWriteTime
        if ($cacheAge.TotalHours -lt 24) {
            Write-Log "Flutter docs cache is fresh ($([int]$cacheAge.TotalHours)h old)" $LogPath
            Write-Host "  Cache is fresh ($([int]$cacheAge.TotalHours)h old)" -ForegroundColor Gray
            return
        }
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would fetch Flutter docs" -ForegroundColor Yellow
        return
    }
    
    # Fetch Flutter API docs index
    try {
        # Use web_fetch via Qwen Code if available, otherwise use Invoke-WebRequest
        $flutterApiUrl = "https://api.flutter.dev/flutter/index.json"
        
        Write-Log "Fetching: $flutterApiUrl" $LogPath
        $response = Invoke-WebRequest -Uri $flutterApiUrl -UseBasicParsing -TimeoutSec 30
        
        # Save index
        $response.Content | Out-File -FilePath "$CacheDir\api-index.json" -Encoding UTF8
        
        # Fetch key documentation pages
        $importantPages = @(
            @{ Url = "https://docs.flutter.dev/get-started/install"; File = "install-guide.md" },
            @{ Url = "https://docs.flutter.dev/testing/overview"; File = "testing-guide.md" },
            @{ Url = "https://docs.flutter.dev/perf/rendering-performance"; File = "performance-guide.md" }
        )
        
        foreach ($page in $importantPages) {
            try {
                Write-Log "Fetching page: $($page.Url)" $LogPath
                $pageResponse = Invoke-WebRequest -Uri $page.Url -UseBasicParsing -TimeoutSec 30
                
                # Extract main content (simplified - would need proper HTML parsing)
                $content = $pageResponse.Content
                
                # Save
                $content | Out-File -FilePath "$CacheDir\$($page.File)" -Encoding UTF8
                Write-Host "  Fetched: $($page.File)" -ForegroundColor Gray
            }
            catch {
                Write-Log "Failed to fetch $($page.Url): $($_.Exception.Message)" $LogPath -Level Warning
            }
        }
        
        # Create index
        $index = @{
            Source = "Flutter"
            FetchedAt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            Files = (Get-ChildItem -Path $CacheDir -File | Select-Object -ExpandProperty Name)
            Version = "latest"
        }
        
        $index | ConvertTo-Json | Out-File -FilePath $cacheIndex -Encoding UTF8
        
        Write-Log "Flutter docs fetched successfully" $LogPath
        Write-Host "  Flutter docs updated" -ForegroundColor Green
    }
    catch {
        Write-Log "Failed to fetch Flutter docs: $($_.Exception.Message)" $LogPath -Level Error
        Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Fetch-DartDocs {
    param(
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Host "`nFetching Dart documentation..." -ForegroundColor Cyan
    Write-Log "Fetching Dart docs to $CacheDir" $LogPath
    
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    
    # Check cache age
    $cacheIndex = "$CacheDir\index.json"
    if (Test-Path $cacheIndex -and -not $Force) {
        $cacheAge = (Get-Date) - (Get-Item $cacheIndex).LastWriteTime
        if ($cacheAge.TotalHours -lt 24) {
            Write-Log "Dart docs cache is fresh ($([int]$cacheAge.TotalHours)h old)" $LogPath
            Write-Host "  Cache is fresh ($([int]$cacheAge.TotalHours)h old)" -ForegroundColor Gray
            return
        }
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would fetch Dart docs" -ForegroundColor Yellow
        return
    }
    
    try {
        # Fetch Dart API docs
        $dartApiUrl = "https://dart.dev/guides/libraries/library-tour"
        
        Write-Log "Fetching: $dartApiUrl" $LogPath
        $response = Invoke-WebRequest -Uri $dartApiUrl -UseBasicParsing -TimeoutSec 30
        
        # Save
        $response.Content | Out-File -FilePath "$CacheDir\library-tour.html" -Encoding UTF8
        
        # Fetch language guide
        $langGuideUrl = "https://dart.dev/guides/language/language-tour"
        $langResponse = Invoke-WebRequest -Uri $langGuideUrl -UseBasicParsing -TimeoutSec 30
        $langResponse.Content | Out-File -FilePath "$CacheDir\language-tour.html" -Encoding UTF8
        
        # Create index
        $index = @{
            Source = "Dart"
            FetchedAt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            Files = (Get-ChildItem -Path $CacheDir -File | Select-Object -ExpandProperty Name)
            Version = "latest"
        }
        
        $index | ConvertTo-Json | Out-File -FilePath $cacheIndex -Encoding UTF8
        
        Write-Log "Dart docs fetched successfully" $LogPath
        Write-Host "  Dart docs updated" -ForegroundColor Green
    }
    catch {
        Write-Log "Failed to fetch Dart docs: $($_.Exception.Message)" $LogPath -Level Error
        Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Fetch-PubDevPackages {
    param(
        [string]$PubSpecPath,
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Host "`nFetching Pub.dev package documentation..." -ForegroundColor Cyan
    
    if (-not (Test-Path $PubSpecPath)) {
        Write-Log "pubspec.yaml not found: $PubSpecPath" $LogPath -Level Error
        Write-Host "  pubspec.yaml not found" -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    
    # Parse pubspec.yaml to get dependencies
    $pubspecContent = Get-Content $PubSpecPath -Raw
    $dependencies = @()
    
    # Simple YAML parsing for dependencies
    $inDependencies = $false
    $lines = $pubspecContent -split "`n"
    
    foreach ($line in $lines) {
        if ($line -match "^dependencies:") {
            $inDependencies = $true
            continue
        }
        if ($line -match "^dev_dependencies:") {
            $inDependencies = $false
            continue
        }
        if ($inDependencies -and $line -match "^\s{2}(\w+):") {
            $dependencies += $matches[1]
        }
    }
    
    Write-Log "Found $($dependencies.Count) dependencies in pubspec.yaml" $LogPath
    
    foreach ($package in $dependencies) {
        Fetch-PubDevPackage -PackageName $package -CacheDir $CacheDir -Force:$Force -DryRun:$DryRun
    }
}

function Fetch-PubDevPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Log "Fetching package: $PackageName" $LogPath
    
    $packageDir = "$CacheDir\$PackageName"
    if (-not (Test-Path $packageDir)) {
        New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
    }
    
    # Check cache age
    $cacheIndex = "$packageDir\index.json"
    if (Test-Path $cacheIndex -and -not $Force) {
        $cacheAge = (Get-Date) - (Get-Item $cacheIndex).LastWriteTime
        if ($cacheAge.TotalHours -lt 24) {
            Write-Log "Package $PackageName cache is fresh" $LogPath
            return
        }
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would fetch package: $PackageName" -ForegroundColor Yellow
        return
    }
    
    try {
        # Fetch package page
        $packageUrl = "https://pub.dev/packages/$PackageName"
        Write-Log "Fetching: $packageUrl" $LogPath
        
        $response = Invoke-WebRequest -Uri $packageUrl -UseBasicParsing -TimeoutSec 30
        
        # Save package page
        $response.Content | Out-File -FilePath "$packageDir\package.html" -Encoding UTF8
        
        # Fetch API docs if available
        $apiDocsUrl = "https://pub.dev/documentation/$PackageName/latest/"
        try {
            $apiResponse = Invoke-WebRequest -Uri $apiDocsUrl -UseBasicParsing -TimeoutSec 30
            $apiResponse.Content | Out-File -FilePath "$packageDir\api-docs.html" -Encoding UTF8
        }
        catch {
            Write-Log "No API docs available for $PackageName" $LogPath -Level Debug
        }
        
        # Fetch changelog
        $changelogUrl = "https://raw.githubusercontent.com/dart-lang/packages/main/packages/$PackageName/CHANGELOG.md"
        try {
            $changelogResponse = Invoke-WebRequest -Uri $changelogUrl -UseBasicParsing -TimeoutSec 10
            $changelogResponse.Content | Out-File -FilePath "$packageDir\CHANGELOG.md" -Encoding UTF8
        }
        catch {
            Write-Log "No changelog found for $PackageName" $LogPath -Level Debug
        }
        
        # Create index
        $index = @{
            Package = $PackageName
            FetchedAt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            Files = (Get-ChildItem -Path $packageDir -File | Select-Object -ExpandProperty Name)
        }
        
        $index | ConvertTo-Json | Out-File -FilePath $cacheIndex -Encoding UTF8
        
        Write-Host "  Fetched: $PackageName" -ForegroundColor Gray
    }
    catch {
        Write-Log "Failed to fetch package $PackageName`: $($_.Exception.Message)" $LogPath -Level Error
        Write-Host "  Failed to fetch: $PackageName" -ForegroundColor Red
    }
}

function Fetch-QwenDocs {
    param(
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Host "`nFetching Qwen Code framework documentation..." -ForegroundColor Cyan
    Write-Log "Fetching Qwen docs to $CacheDir" $LogPath
    
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    
    # Check cache age
    $cacheIndex = "$CacheDir\index.json"
    if (Test-Path $cacheIndex -and -not $Force) {
        $cacheAge = (Get-Date) - (Get-Item $cacheIndex).LastWriteTime
        if ($cacheAge.TotalHours -lt 48) {
            Write-Log "Qwen docs cache is fresh ($([int]$cacheAge.TotalHours)h old)" $LogPath
            Write-Host "  Cache is fresh ($([int]$cacheAge.TotalHours)h old)" -ForegroundColor Gray
            return
        }
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would fetch Qwen docs" -ForegroundColor Yellow
        return
    }
    
    try {
        # Copy local Qwen documentation
        $qwenDir = "$PSScriptRoot\..\..\.."
        
        # Copy AGENTS.md
        if (Test-Path "$qwenDir\AGENTS.md") {
            Copy-Item "$qwenDir\AGENTS.md" "$CacheDir\AGENTS.md" -Force
        }
        
        # Copy QWEN.md
        if (Test-Path "$qwenDir\QWEN.md") {
            Copy-Item "$qwenDir\QWEN.md" "$CacheDir\QWEN.md" -Force
        }
        
        # Copy agent definitions
        $agentsDir = "$CacheDir\agents"
        if (-not (Test-Path $agentsDir)) {
            New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
        }
        
        if (Test-Path "$qwenDir\.qwen\agents") {
            Get-ChildItem "$qwenDir\.qwen\agents" -Filter "*.md" | ForEach-Object {
                Copy-Item $_.FullName "$agentsDir\" -Force
            }
        }
        
        # Copy skill definitions
        $skillsDir = "$CacheDir\skills"
        if (-not (Test-Path $skillsDir)) {
            New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
        }
        
        if (Test-Path "$qwenDir\.qwen\skills") {
            Get-ChildItem "$qwenDir\.qwen\skills" -Directory | ForEach-Object {
                $skillSubDir = "$skillsDir\$($_.Name)"
                New-Item -ItemType Directory -Path $skillSubDir -Force | Out-Null
                
                if (Test-Path "$($_.FullName)\SKILL.md") {
                    Copy-Item "$($_.FullName)\SKILL.md" "$skillSubDir\" -Force
                }
            }
        }
        
        # Create index
        $index = @{
            Source = "Qwen Code"
            FetchedAt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            Files = (Get-ChildItem -Path $CacheDir -File -Recurse | Select-Object -ExpandProperty FullName)
        }
        
        $index | ConvertTo-Json | Out-File -FilePath $cacheIndex -Encoding UTF8
        
        Write-Log "Qwen docs fetched successfully" $LogPath
        Write-Host "  Qwen docs updated" -ForegroundColor Green
    }
    catch {
        Write-Log "Failed to fetch Qwen docs: $($_.Exception.Message)" $LogPath -Level Error
        Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Fetch-SupabaseDocs {
    param(
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Host "`nFetching Supabase documentation..." -ForegroundColor Cyan
    Write-Log "Fetching Supabase docs to $CacheDir" $LogPath
    
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would fetch Supabase docs" -ForegroundColor Yellow
        return
    }
    
    # Fetch key Supabase documentation pages
    $pages = @(
        @{ Url = "https://supabase.com/docs/reference/dart/introduction"; File = "dart-intro.md" },
        @{ Url = "https://supabase.com/docs/guides/database"; File = "database-guide.md" }
    )
    
    foreach ($page in $pages) {
        try {
            $response = Invoke-WebRequest -Uri $page.Url -UseBasicParsing -TimeoutSec 30
            $response.Content | Out-File -FilePath "$CacheDir\$($page.File)" -Encoding UTF8
            Write-Host "  Fetched: $($page.File)" -ForegroundColor Gray
        }
        catch {
            Write-Log "Failed to fetch $($page.Url)" $LogPath -Level Warning
        }
    }
}

function Fetch-AzureDocs {
    param(
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Host "`nFetching Azure documentation..." -ForegroundColor Cyan
    Write-Log "Fetching Azure docs to $CacheDir" $LogPath
    
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would fetch Azure docs" -ForegroundColor Yellow
        return
    }
    
    # Fetch key Azure documentation pages
    $pages = @(
        @{ Url = "https://learn.microsoft.com/azure/developer/java/azure-tools"; File = "azure-tools.md" }
    )
    
    foreach ($page in $pages) {
        try {
            $response = Invoke-WebRequest -Uri $page.Url -UseBasicParsing -TimeoutSec 30
            $response.Content | Out-File -FilePath "$CacheDir\$($page.File)" -Encoding UTF8
            Write-Host "  Fetched: $($page.File)" -ForegroundColor Gray
        }
        catch {
            Write-Log "Failed to fetch $($page.Url)" $LogPath -Level Warning
        }
    }
}

function Fetch-GoogleAIDocs {
    param(
        [string]$CacheDir,
        [switch]$Force,
        [switch]$DryRun
    )
    
    Write-Host "`nFetching Google AI documentation..." -ForegroundColor Cyan
    Write-Log "Fetching Google AI docs to $CacheDir" $LogPath
    
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would fetch Google AI docs" -ForegroundColor Yellow
        return
    }
    
    # Fetch key Google AI documentation pages
    $pages = @(
        @{ Url = "https://ai.google.dev/docs"; File = "ai-docs.md" }
    )
    
    foreach ($page in $pages) {
        try {
            $response = Invoke-WebRequest -Uri $page.Url -UseBasicParsing -TimeoutSec 30
            $response.Content | Out-File -FilePath "$CacheDir\$($page.File)" -Encoding UTF8
            Write-Host "  Fetched: $($page.File)" -ForegroundColor Gray
        }
        catch {
            Write-Log "Failed to fetch $($page.Url)" $LogPath -Level Warning
        }
    }
}
