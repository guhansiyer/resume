param(
    [switch]$WWOrdering,
    [switch]$SkillsFirst
)

$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
$rootDir   = Split-Path $scriptDir -Parent

$srcDir    = Join-Path $rootDir "src"
$orderFile = Join-Path $srcDir "order.tex"

$buildDir  = Join-Path $rootDir ".latex-build"
$finalPdf  = Join-Path $rootDir "resume.pdf"
$jobName   = "resume"

if (Test-Path $buildDir) {
    Remove-Item -Path $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

$skillsFirstEnabled = $WWOrdering -or $SkillsFirst
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if ($skillsFirstEnabled) {
    Write-Host "Building with Skills before Education"
    $orderContent = "% Auto-generated`n\newif\ifskillsfirst`n\skillsfirsttrue`n"
} else {
    Write-Host "Building with Education before Skills"
    $orderContent = "% Auto-generated`n\newif\ifskillsfirst`n\skillsfirstfalse`n"
}
[System.IO.File]::WriteAllText($orderFile, $orderContent, $utf8NoBom)

try {
    for ($pass = 1; $pass -le 2; $pass++) {
        $process = Start-Process pdflatex `
            -WorkingDirectory $srcDir `
            -ArgumentList "-interaction=nonstopmode", "-halt-on-error", "-output-directory=$buildDir", "resume.tex" `
            -PassThru -Wait -NoNewWindow

        if ($process.ExitCode -ne 0) {
            Write-Host "Compilation failed on pass $pass with exit code: $($process.ExitCode)"
            $logPath = Join-Path $buildDir "$jobName.log"
            Get-Content $logPath -ErrorAction SilentlyContinue
            exit $process.ExitCode
        }
    }

    $pdfPath = Join-Path $buildDir "$jobName.pdf"
    if (Test-Path $pdfPath) {
        Copy-Item -Path $pdfPath -Destination $finalPdf -Force
        Write-Host "Wrote: $finalPdf"
    } else {
        Write-Host "Error: expected PDF not found at $pdfPath"
        exit 1
    }
} finally {
    Remove-Item -Path $buildDir -Recurse -Force -ErrorAction SilentlyContinue
}