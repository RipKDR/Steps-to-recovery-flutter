param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$localPropertiesPath = Join-Path $projectRoot "android\local.properties"

function Get-FlutterExecutable {
    if (Test-Path $localPropertiesPath) {
        $flutterSdkLine = Get-Content $localPropertiesPath | Where-Object {
            $_ -match '^flutter\.sdk='
        } | Select-Object -First 1

        if ($flutterSdkLine) {
            $flutterSdk = ($flutterSdkLine -replace '^flutter\.sdk=', '') -replace '\\\\', '\'
            $flutterBat = Join-Path $flutterSdk "bin\flutter.bat"
            if (Test-Path $flutterBat) {
                return $flutterBat
            }
        }
    }

    if ($env:FLUTTER_ROOT) {
        $flutterBat = Join-Path $env:FLUTTER_ROOT "bin\flutter.bat"
        if (Test-Path $flutterBat) {
            return $flutterBat
        }
    }

    $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCommand) {
        return $flutterCommand.Source
    }

    throw "Flutter SDK not found. Set flutter.sdk in android/local.properties, set FLUTTER_ROOT, or add flutter to PATH."
}

function Quote-PowerShellArg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    return "'" + ($Value -replace "'", "''") + "'"
}

$flutterExecutable = Get-FlutterExecutable
$commandParts = @("&", (Quote-PowerShellArg -Value $flutterExecutable))
$commandParts += $FlutterArgs | ForEach-Object { Quote-PowerShellArg -Value $_ }
$command = $commandParts -join " "

Push-Location $projectRoot
try {
    Invoke-Expression $command
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
