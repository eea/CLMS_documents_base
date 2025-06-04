#!/bin/bash

# Ensure the script is run from the project root
#
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$REPO_ROOT" ]; then
  echo "❌ Not inside a Git repository. Please run this script from a Git project."
  exit 1
fi

cd "$REPO_ROOT" || exit 1


# Esential variables
#
ALIAS_FILE="DOCS/_meta/config/git-docs-aliases.conf"
ALIAS_PATH="$REPO_ROOT/$ALIAS_FILE"


# Configure .git/config to include our alias file
#

# Make sure the alias file exists
if [ ! -f "$ALIAS_PATH" ]; then
  echo "❌ Alias file not found: $ALIAS_PATH"
  echo "➡️  Please check if DOCS/config/git-docs-aliases.conf exists."
  exit 1
fi

# Link the docs-aliases file into .git/config
if git config --local --get-all include.path | grep -Fxq "../$ALIAS_FILE"; then
  echo "✅ .git/config already includes $ALIAS_FILE"
else
  echo "🔗 Linking ../$ALIAS_FILE into .git/config..."
  git config --local --add include.path "../$ALIAS_FILE"
fi

echo "✅ Git aliases setup complete. You can now use:"
# Extract alias names
grep -E '^\s*[a-zA-Z0-9-]+ *=' "$ALIAS_PATH" | while IFS='=' read -r alias_name _; do
  alias_name_clean=$(echo "$alias_name" | xargs)
  echo "   git $alias_name_clean"
done

echo ""
