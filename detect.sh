#!/bin/bash

# Get the current commit hash
current_commit=$(git rev-parse HEAD)

# Get the previous commit hash if it exists
if git rev-parse HEAD^ &>/dev/null; then
    previous_commit=$(git rev-parse HEAD^)
else
    previous_commit=""
fi

# Check if the current commit is a rollback to a previous tag
if [ "$(git tag --contains $current_commit)" = "" ]; then
    echo "Rollback detected"
    
    # Trigger GitHub Actions workflow
    response=$(curl -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GIT_TOKEN" \
        -d '{"ref": "main"}' \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/workflows/roll_back_trigger/dispatches")

    if [ "$(echo "$response" | jq -r '.message')" = "Bad credentials" ]; then
        echo "Error: Bad credentials. Please ensure that your GitHub token is valid."
    elif [ "$(echo "$response" | jq -r '.id')" != "" ]; then
        echo "Workflow dispatch successfully triggered."
    else
        echo "Error: Failed to trigger workflow dispatch."
    fi
else
    echo "No rollback detected"
fi
