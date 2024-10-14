#!/bin/bash

# Set up the git repository path
REPO_PATH="/path/to/your/repo"

# Navigate to the repository
cd $REPO_PATH

# Add config file to git
git add config.rsc

# Commit the changes with a timestamp
git commit -m "Backup config at $(date)"

# Push the changes to the remote repository
git push
