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
    response=$(curl -X PATCH \
        -H "Authorization: token $GIT_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/latest" \
        -d "{\"tag_name\": \"v0.2\"}")

    if [ "$(echo "$response" | jq -r '.message')" = "Bad credentials" ]; then
        echo "Error: Bad credentials. Please ensure that your GitHub token is valid."
    elif [ "$(echo "$response" | jq -r '.id')" != "" ]; then
        echo "Release version successfully updated to v0.2."
    else
        echo "Error: Failed to update release version."
    fi
else
    echo "No rollback detected"
fi
