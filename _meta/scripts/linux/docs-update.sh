#!/bin/bash

# Essential variables
REPO_REMOTE="clms-docs-base"     
REPO_BRANCH="main"          
DOC_PATH="DOCS"             

# Make sure we are in the project root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$REPO_ROOT" ]; then
  echo "❌ Not inside a Git repository."
  exit 1
fi

if [ -n "$(git status --porcelain "$DOC_PATH/")" ]; then
  echo "❌ Cannot update $DOC_PATH/ because there are uncommitted changes inside it."
  echo "➡️  Please commit or stash your changes in $DOC_PATH/ before running this update."
  exit 1
fi

echo "🔄 Fetching latest changes from '$REPO_REMOTE'..."
git fetch "$REPO_REMOTE"

echo "📥 Pulling updates from '$REPO_REMOTE/$REPO_BRANCH' into '$DOC_PATH/'..."
git subtree pull --prefix="$DOC_PATH" "$REPO_REMOTE" "$REPO_BRANCH" --squash

echo "✅ $DOC_PATH/ folder updated from $REPO_REMOTE/$REPO_BRANCH"