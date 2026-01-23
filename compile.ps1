param(
    [switch]$WWOrdering
)

$texFile = "GI_Resume.tex"
$outputDir = "output"
$orderFile = "sections\order.tex"

# Ensure output directory exists
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Write order switch
if ($WWOrdering) {
    Write-Host "Building with Skills before Education"
    @"
% Auto-generated
\newif\ifskillsfirst
\skillsfirsttrue
"@ | Set-Content $orderFile
}
else {
    Write-Host "Building with Education before Skills"
    @"
% Auto-generated
\newif\ifskillsfirst
\skillsfirstfalse
"@ | Set-Content $orderFile
}

# Run pdflatex
$ErrorActionPreference = 'Continue'
$process = Start-Process pdflatex -ArgumentList "-output-directory=$outputDir", $texFile -PassThru -Wait -NoNewWindow

# Detailed error checking
if ($process.ExitCode -ne 0) {
    Write-Host "Compilation failed with exit code: $($process.ExitCode)"
    Get-Content "$outputDir\GI_Resume.log" -ErrorAction SilentlyContinue
}
