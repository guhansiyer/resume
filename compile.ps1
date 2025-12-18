# Explicit error handling and logging
$texFile = "GI_Resume.tex"
$outputDir = "output"

# Ensure output directory exists
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Verbose pdflatex execution with error capture
$ErrorActionPreference = 'Continue'
$process = Start-Process pdflatex -ArgumentList "-output-directory=$outputDir", $texFile -PassThru -Wait -NoNewWindow
$process.WaitForExit()

# Detailed error checking
if ($process.ExitCode -ne 0) {
    Write-Host "Compilation failed with exit code: $($process.ExitCode)"
    Get-Content "$outputDir\resume.log" -ErrorAction SilentlyContinue
}