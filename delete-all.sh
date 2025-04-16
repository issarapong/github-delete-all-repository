#!/bin/bash

# GitHub API token - Replace with your own token with repo delete permissions
# You can create one at https://github.com/settings/tokens
TOKEN="your_github_personal_access_token"

# Check if token is set
if [ "$TOKEN" = "your_github_personal_access_token" ]; then
    echo "Error: Please set your GitHub personal access token in the script."
    exit 1
fi

# GitHub username - Replace with your username
USERNAME="your_github_username"

# Fetch all repositories
echo "Fetching repositories for user $USERNAME..."
REPOS=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/user/repos?per_page=100")

# Check if API call was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch repositories. Check your token and internet connection."
    exit 1
fi

# Count repositories
REPO_COUNT=$(echo "$REPOS" | grep -o '"name":' | wc -l)
echo "Found $REPO_COUNT repositories"

# Confirmation
echo "WARNING: This will DELETE ALL repositories for $USERNAME"
echo "This action cannot be undone!"
read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Delete each repository
echo "$REPOS" | grep -o '"name": *"[^"]*"' | cut -d'"' -f4 | while read REPO_NAME; do
    echo "Deleting repository: $REPO_NAME"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE -H "Authorization: token $TOKEN" "https://api.github.com/repos/$USERNAME/$REPO_NAME")
    
    if [ "$HTTP_STATUS" = "204" ]; then
        echo "Successfully deleted $REPO_NAME"
    else
        echo "Failed to delete $REPO_NAME (HTTP Status: $HTTP_STATUS)"
    fi
    
    # Slight delay to avoid rate limiting
    sleep 1
done

echo "Repository deletion process complete."
