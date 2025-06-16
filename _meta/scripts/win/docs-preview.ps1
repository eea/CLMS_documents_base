# Stop on first error
$ErrorActionPreference = "Stop"

if (-not (Get-Command quarto -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Quarto is not installed or not in PATH."
    Write-Host "➡️ Download it from: https://quarto.org/docs/get-started/"
    exit 1
}

# Resolve directories
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DOCS_DIR = Resolve-Path (Join-Path $SCRIPT_DIR "..\..\..")

$META_DIR = Join-Path $DOCS_DIR "_meta"

# Track copied files for cleanup
$COPIED_INDEX_FILES = @(
    Join-Path $DOCS_DIR "index.qmd"
)

# Define cleanup function
function Cleanup {
    Write-Host "🧹 Cleaning up temporary files..."
    foreach ($file in $COPIED_INDEX_FILES) {
        if (Test-Path $file) {
            Remove-Item -Force $file
        }
    }
    $previewDir = Join-Path $DOCS_DIR "_preview"
    if (Test-Path $previewDir) {
        Remove-Item -Recurse -Force $previewDir
    }
}

# Register cleanup on script exit or interruption
$null = Register-EngineEvent PowerShell.Exiting -Action { Cleanup }
$null = Register-EngineEvent ConsoleCancelEventHandler -Action { Cleanup }

# Render main docs
Write-Host "🔧 Rendering documents..."
quarto render "$DOCS_DIR" --to html

# Prepare and render index.qmd
Write-Host "🔧 Rendering index.qmd file..."
Copy-Item -Force (Join-Path $META_DIR "index.qmd") (Join-Path $DOCS_DIR "index.qmd")
Copy-Item -Force (Join-Path $DOCS_DIR "_quarto.yml") (Join-Path $DOCS_DIR "_quarto-not-used.yml")
Copy-Item -Force (Join-Path $META_DIR "_quarto-index.yml") (Join-Path $DOCS_DIR "_quarto.yml")

quarto render (Join-Path $DOCS_DIR "index.qmd") --to html --no-clean

Move-Item -Force (Join-Path $DOCS_DIR "_quarto-not-used.yml") (Join-Path $DOCS_DIR "_quarto.yml")

# Start preview server
quarto preview "$DOCS_DIR" --to html