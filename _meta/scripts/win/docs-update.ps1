# Essential variables
$REPO_REMOTE = "clms-docs-base"
$REPO_BRANCH = "main"
$DOC_PATH = "DOCS"

# Ensure we're in a Git repository
$REPO_ROOT = git rev-parse --show-toplevel 2>$null
if (-not $REPO_ROOT) {
    Write-Host "❌ Not inside a Git repository."
    exit 1
}

# Check for uncommitted changes in DOC_PATH
$changes = git status --porcelain $DOC_PATH 2>$null
if ($changes) {
    Write-Host "❌ Cannot update $DOC_PATH/ because there are uncommitted changes inside it."
    Write-Host "➡️  Please commit or stash your changes in $DOC_PATH/ before running this update."
    exit 1
}

# Fetch and update
Write-Host "🔄 Fetching latest changes from '$REPO_REMOTE'..."
git fetch $REPO_REMOTE

Write-Host "📥 Pulling updates from '$REPO_REMOTE/$REPO_BRANCH' into '$DOC_PATH/'..."
git subtree pull --prefix=$DOC_PATH $REPO_REMOTE $REPO_BRANCH --squash

Write-Host "✅ $DOC_PATH/ folder updated from $REPO_REMOTE/$REPO_BRANCH"
