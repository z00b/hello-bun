#!/usr/bin/env bash

# Release function for hello-bun
# Usage: release <version> <message>
# Example: release 1.0.0 "First stable release"

release() {
  # Check if correct number of arguments
  if [ $# -ne 2 ]; then
    echo "Usage: release <dot-version> <message>"
    echo "Example: release 16 \"Release #16\""
    return 1
  fi

  local version="$1"
  local message="$2"
  local tag="v0.0.${version}"

  # Ensure we're on main branch
  local current_branch=$(git branch --show-current)
  if [ "$current_branch" != "main" ]; then
    echo "Error: Not on main branch (currently on: $current_branch)"
    echo "Switch to main branch first: git checkout main"
    return 1
  fi

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo "Found uncommitted changes. Proceeding with release..."
    echo ""
  fi

  # Check if tag already exists
  if git rev-parse "$tag" >/dev/null 2>&1; then
    echo "Error: Tag $tag already exists"
    echo "Use: git tag -d $tag  # to delete locally"
    echo "And: git push origin :refs/tags/$tag  # to delete remotely"
    return 1
  fi

  # Show what will be done
  echo "Release Plan:"
  echo "  Version: $version"
  echo "  Tag: $tag"
  echo "  Message: $message"
  echo "  Branch: main"
  echo ""

  # Perform release steps
  echo ""
  echo "Step 1/4: Adding files..."
  git add . || { echo "Error: git add failed"; return 1; }

  echo "Step 2/4: Committing changes..."
  git commit -m "$message" || {
    echo "Warning: No changes to commit (this is OK if everything was already committed)"
  }

  echo "Step 3/4: Creating tag $tag..."
  git tag -a "$tag" -m "$message" || { echo "Error: git tag failed"; return 1; }

  echo "Step 4/4: Pushing to origin main with tags..."
  git push origin $tag || { echo "Error: git push failed"; return 1; }

  echo ""
  echo "✅ Release $tag completed successfully!"
}

# Export the function
export -f release

# If sourced, just define the function
# If executed, show usage
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  echo "This file should be sourced, not executed directly."
  echo ""
  echo "Usage:"
  echo "  source release.sh"
  echo "  release <version> <message>"
  echo ""
  echo "Example:"
  echo "  source release.sh"
  echo "  release 1.0.0 \"First stable release\""
fi
