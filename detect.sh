#!/bin/bash

# Get the current commit hash
current_commit=$(git rev-parse HEAD)

# Get the previous commit hash
previous_commit=$(git rev-parse HEAD^)

# Check if the current commit is a rollback to a previous tag
if [ "$(git tag --contains $current_commit)" = "" ]; then
    echo "Rollback detected"
    # Trigger GitHub Actions workflow
    curl -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: Bearer $GIT_TOKEN" \
      "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/workflows/roll_back_trigger/dispatches" \
      -d '{"ref": "main"}'
else
    echo "No rollback detected"
fi
