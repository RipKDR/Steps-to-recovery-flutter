[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('analyze', 'test', 'l10n', 'apk-debug', 'apk-release', 'pr-gate', 'main-build')]
    [string]$Command
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSNativeCommandUseErrorActionPreference = $true
}

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

function Get-FlutterInvoker {
    $onWindowsPlatform =
        [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
            [System.Runtime.InteropServices.OSPlatform]::Windows
        )

    if ($onWindowsPlatform) {
        $flutterwPath = Join-Path $PSScriptRoot 'flutterw.ps1'
        if (Test-Path $flutterwPath) {
            return @{
                Type = 'Script'
                Path = $flutterwPath
            }
        }
    }

    $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCommand) {
        return @{
            Type = 'Command'
            Path = $flutterCommand.Source
        }
    }

    throw "Flutter SDK not found. On Windows, ensure tool/flutterw.ps1 can resolve the SDK. On other platforms, ensure flutter is available on PATH."
}

function Invoke-Flutter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    $flutter = Get-FlutterInvoker
    if ($flutter.Type -eq 'Script') {
        & $flutter.Path -FlutterArgs $Args
    }
    else {
        & $flutter.Path @Args
    }

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

function Invoke-Analyze {
    Invoke-Flutter -Args @('analyze')
}

function Invoke-Test {
    Invoke-Flutter -Args @('test', '--coverage')
}

function Invoke-L10n {
    Invoke-Flutter -Args @('gen-l10n')
}

function Invoke-ApkDebug {
    Invoke-Flutter -Args @('build', 'apk', '--debug')
}

function Invoke-ApkRelease {
    Invoke-Flutter -Args @('build', 'apk', '--release')
}

function Invoke-PubGet {
    Invoke-Flutter -Args @('pub', 'get')
}

switch ($Command) {
    'analyze' {
        Invoke-Analyze
    }
    'test' {
        Invoke-Test
    }
    'l10n' {
        Invoke-L10n
    }
    'apk-debug' {
        Invoke-ApkDebug
    }
    'apk-release' {
        Invoke-ApkRelease
    }
    'pr-gate' {
        Invoke-PubGet
        Invoke-L10n
        Invoke-Analyze
        Invoke-Test
    }
    'main-build' {
        Invoke-PubGet
        Invoke-L10n
        Invoke-Analyze
        Invoke-Test
        Invoke-ApkRelease
    }
}
