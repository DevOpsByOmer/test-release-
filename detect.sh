#!/bin/bash

# Get the current commit hash
current_commit=$(git rev-parse HEAD)

# Get the previous commit hash
previous_commit=$(git rev-parse HEAD^)

# Check if the current commit is a rollback to a previous tag
if [ "$(git tag --contains $current_commit)" = "" ]; then
    echo "Rollback detected"
    # Trigger GitHub Actions workflow
    # Insert code here to trigger the workflow using the GitHub API
else
    echo "No rollback detected"
fi
