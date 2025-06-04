# Safe wrapper for git commands
run_git() {
    local description="$1"
    shift
    git "$@" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ Fatal error during: $description"
        exit 1
    fi
}

# Function to normalize project name
# - lowercase
# - replace spaces/underscores with hyphens
# - remove non-alphanumeric characters (except hyphens)
normalize_project_name() {
  local raw_name="$1"
  echo "$raw_name" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/ /-/g' -e 's/_/-/g' -e 's/[^a-z0-9\-]//g'
}