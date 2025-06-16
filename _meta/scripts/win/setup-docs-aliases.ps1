# Ensure the script is run from the project root
$REPO_ROOT = git rev-parse --show-toplevel 2>$null

if (-not $REPO_ROOT) {
    Write-Host "❌ Not inside a Git repository. Please run this script from a Git project."
    exit 1
}

Set-Location $REPO_ROOT

# Essential variables
$ALIAS_FILE = "DOCS/_meta/config/git-docs-aliases-windows.conf"
$ALIAS_PATH = Join-Path $REPO_ROOT $ALIAS_FILE

# Ensure the alias file exists
if (-not (Test-Path $ALIAS_PATH)) {
    Write-Host "❌ Alias file not found: $ALIAS_PATH"
    Write-Host "➡️  Please check if DOCS/config/git-docs-aliases-windows.conf exists."
    exit 1
}

# Check if the alias is already included
$existingIncludes = git config --local --get-all include.path 2>$null
if ($existingIncludes -contains "../$ALIAS_FILE") {
    Write-Host "✅ .git/config already includes $ALIAS_FILE"
} else {
    Write-Host "🔗 Linking ../$ALIAS_FILE into .git/config..."
    git config --local --add include.path "../$ALIAS_FILE"
}

Write-Host "✅ Git aliases setup complete. You can now use:"

# Display all aliases from the file
Get-Content $ALIAS_PATH | ForEach-Object {
    if ($_ -match '^\s*([a-zA-Z0-9\-]+)\s*=') {
        $aliasName = $matches[1].Trim()
        Write-Host "   git $aliasName"
    }
}

Write-Host ""