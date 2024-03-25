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
    
    # Update release version if necessary
    if [ "$(git tag --contains $current_commit)" != 'v0.2' ]; then
        updated_version="v0.2"
        echo "Updating release version to $updated_version"
        
        # Get the release ID of the latest release
        release_id=$(curl -s -H "Authorization: token $GIT_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" | jq -r '.id')
        
        # Patch the release with the updated version
        curl -X PATCH \
            -H "Authorization: token $GIT_TOKEN" \
            -H "Content-Type: application/json" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/$release_id" \
            -d "{\"tag_name\": \"$updated_version\"}"
    fi
else
    echo "No rollback detected"
fi
