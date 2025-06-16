#!/bin/bash

# Essential confg
#----------------
REPO_FINAL_URL="git@github.com:eea/CLMS_documents.git"
DOC_PATH="DOCS"
#----------------

# Make sure we are in the project root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  echo "❌ Not inside a Git repository."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/utils.sh"

# Automatically detect project name from Git repository
RAW_PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
PROJECT_NAME=$(normalize_project_name "$RAW_PROJECT_NAME")
TARGET_FOLDER="DOCS/${PROJECT_NAME}"

# Variables for versioning
TIMESTAMP=$(date -u +"%Y%m%d-%H%M%S")
PUBLISH_BRANCH="publish-${PROJECT_NAME}-${TIMESTAMP}"
TAG_NAME="v-${PROJECT_NAME}-${TIMESTAMP}"

cd "$REPO_ROOT" || exit 1

# Create split branch from DOCS
echo "📦 Creating snapshot of '${DOC_PATH}/'..."
run_git "subtree split" subtree split --prefix="$DOC_PATH" -b "$PUBLISH_BRANCH"

# Archive and extract to temp dir
TMP_DIR=$(mktemp -d)
mkdir -p "$TMP_DIR/DOCS/$PROJECT_NAME"
git archive "$PUBLISH_BRANCH" | tar -x -C "$TMP_DIR/$TARGET_FOLDER"

# Copy .gitignore from config
cp "$DOC_PATH/_meta/config/publish-gitignore" "$TMP_DIR/.gitignore"

# Inject workflow definition (so it can be triggered by GitHub Actions)
mkdir -p "$TMP_DIR/.github/workflows"
cp "$DOC_PATH/_meta/config/publish-trigger.yml" "$TMP_DIR/.github/workflows/trigger.yml"

# Initialize a fresh Git repo
cd "$TMP_DIR" || exit 1
run_git "init temp repo" init -b temp

# Stage and commit 
run_git "adding files to temp repo" add .
run_git "committing docs" commit -m "chore(publish): ${PROJECT_NAME} docs snapshot at ${TIMESTAMP}"

# Push to final repo
run_git "adding remote final repo" remote add origin "$REPO_FINAL_URL"
run_git "pushing publish branch" push origin HEAD:"$PUBLISH_BRANCH" --force
run_git "creating tag" tag "$TAG_NAME"
run_git "pushing tag" push origin "$TAG_NAME"

echo "✅ Successfully published DOCS for $PROJECT_NAME."

# Clean up
cd "$REPO_ROOT" || exit 1
run_git "deleting temp publish branch" branch -D "$PUBLISH_BRANCH"
rm -rf "$TMP_DIR"

echo "✅ Cleaned up temporary files and branches."
