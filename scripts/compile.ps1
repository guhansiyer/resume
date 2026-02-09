param(
    [switch]$WWOrdering,
    [switch]$SkillsFirst
)

$scriptDir = $PSScriptRoot
$rootDir   = Split-Path $scriptDir -Parent

$srcDir    = Join-Path $rootDir "src"
$orderFile = Join-Path $srcDir "order.tex"

$buildDir  = Join-Path $rootDir ".latex-build"
$finalPdf  = Join-Path $rootDir "GI_Resume.pdf"
$jobName   = "GI_Resume"

New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

# Decide ordering (support old flag + new alias)
$skillsFirstEnabled = $WWOrdering -or $SkillsFirst

if ($skillsFirstEnabled) {
    Write-Host "Building with Skills before Education"
    @"
% Auto-generated
\newif\ifskillsfirst
\skillsfirsttrue
"@ | Set-Content -Path $orderFile -Encoding UTF8
}
else {
    Write-Host "Building with Education before Skills"
    @"
% Auto-generated
\newif\ifskillsfirst
\skillsfirstfalse
"@ | Set-Content -Path $orderFile -Encoding UTF8
}

# Run pdflatex from src/ so \input{order.tex} resolves
$ErrorActionPreference = 'Continue'
$process = Start-Process pdflatex `
    -WorkingDirectory $srcDir `
    -ArgumentList "-interaction=nonstopmode", "-halt-on-error", "-output-directory=$buildDir", "GI_Resume.tex" `
    -PassThru -Wait -NoNewWindow

if ($process.ExitCode -ne 0) {
    Write-Host "Compilation failed with exit code: $($process.ExitCode)"
    $logPath = Join-Path $buildDir "$jobName.log"
    Get-Content $logPath -ErrorAction SilentlyContinue
    exit $process.ExitCode
}

# On success: copy PDF to repo root and delete build dir
$pdfPath = Join-Path $buildDir "$jobName.pdf"
if (Test-Path $pdfPath) {
    Copy-Item -Path $pdfPath -Destination $finalPdf -Force
} else {
    Write-Host "Error: expected PDF not found at $pdfPath"
    exit 1
}

Remove-Item -Path $buildDir -Recurse -Force
Write-Host "Wrote: $finalPdf"
