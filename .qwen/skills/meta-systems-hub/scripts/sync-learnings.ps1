# Sync Learnings from Meta-Systems Hub to Self-Evolving Agent
# Automatically called after hub scans

param(
    [string]$LearningType = "CodeHealth",
    [string]$LearningData
)

$ErrorActionPreference = "Continue"

$HubPath = ".qwen\skills\meta-systems-hub"
$SelfEvolvingPath = ".qwen\skills\self-evolving-agent"
$RememberPath = ".remember\logs\autonomous"

# Ensure directories exist
$learningsDir = "$SelfEvolvingPath\knowledge"
$memoryDir = "$RememberPath"

if (-not (Test-Path $learningsDir)) {
    New-Item -ItemType Directory -Force -Path $learningsDir | Out-Null
}

if (-not (Test-Path $memoryDir)) {
    New-Item -ItemType Directory -Force -Path $memoryDir | Out-Null
}

# Create learning entry
$learning = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Source = "meta-systems-hub"
    Type = $LearningType
    Data = $LearningData
}

# Save to self-evolving-agent knowledge
$learningFile = "$learningsDir\meta-systems-(Get-Date -Format 'yyyy-MM-dd').json"
if (Test-Path $learningFile) {
    $existing = Get-Content $learningFile -Raw | ConvertFrom-Json
    $existing += $learning
    $existing | ConvertTo-Json -Depth 5 | Out-File -FilePath $learningFile -Encoding utf8
} else {
    @($learning) | ConvertTo-Json -Depth 5 | Out-File -FilePath $learningFile -Encoding utf8
}

Write-Host "  Learning synced to self-evolving-agent" -ForegroundColor Green
