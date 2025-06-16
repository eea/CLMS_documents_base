$REPO_FINAL_URL="git@github.com:eea/CLMS_documents.git"
$DOC_PATH = "DOCS"

$REPO_ROOT = git rev-parse --show-toplevel 2>$null
if (-not $REPO_ROOT) {
    Write-Host "❌ Not inside a Git repository."
    exit 1
}

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $SCRIPT_DIR "helpers\utils.ps1")

$RAW_PROJECT_NAME = Split-Path $REPO_ROOT -Leaf
$PROJECT_NAME = Normalize-ProjectName $RAW_PROJECT_NAME
$TARGET_FOLDER = Join-Path "DOCS" $PROJECT_NAME

$TIMESTAMP = (Get-Date -Format "yyyyMMdd-HHmmss")
$PUBLISH_BRANCH = "publish-$PROJECT_NAME-$TIMESTAMP"
$TAG_NAME = "v-$PROJECT_NAME-$TIMESTAMP"

Set-Location $REPO_ROOT

Write-Host "📦 Creating snapshot of '$DOC_PATH/'... '$PUBLISH_BRANCH'"
Run-Git "subtree split" subtree split "--prefix=$DOC_PATH" "-b" $PUBLISH_BRANCH

$TMP_DIR = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_.FullName }
$projectTargetPath = Join-Path $TMP_DIR $TARGET_FOLDER
New-Item -ItemType Directory -Path $projectTargetPath -Force | Out-Null

$zipPath = Join-Path $TMP_DIR "archive.zip"
git archive $PUBLISH_BRANCH -o $zipPath
Expand-Archive -Path $zipPath -DestinationPath $projectTargetPath
Remove-Item $zipPath

Copy-Item (Join-Path $DOC_PATH "_meta\config\publish-gitignore") (Join-Path $TMP_DIR ".gitignore")

$workflowDir = Join-Path $TMP_DIR ".github\workflows"
New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null

Copy-Item (Join-Path $DOC_PATH "_meta\config\publish-trigger.yml") (Join-Path $workflowDir "trigger.yml")

Set-Location $TMP_DIR
Run-Git "init temp repo" init "-b" "temp"
Run-Git "adding files to temp repo" add "."
Run-Git "committing docs" commit "-m" "chore(publish): $PROJECT_NAME docs snapshot at $TIMESTAMP"

Run-Git "adding remote final repo" remote add origin $REPO_FINAL_URL
Run-Git "pushing publish branch" push origin "HEAD:$PUBLISH_BRANCH" "--force"
Run-Git "creating tag" tag $TAG_NAME
Run-Git "pushing tag" push origin $TAG_NAME

Write-Host "✅ Successfully published DOCS for $PROJECT_NAME."

Set-Location $REPO_ROOT
Run-Git "deleting temp publish branch" branch "-D" $PUBLISH_BRANCH
Remove-Item -Recurse -Force $TMP_DIR

Write-Host "✅ Cleaned up temporary files and branches."