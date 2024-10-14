#!/bin/bash

# Set up the Git repository path
#REPO_PATH="/path/to/your/repo"
#CONFIG_PATH="/path/on/server/current-config.rsc"

# Navigate to the repository
#cd $REPO_PATH

# Copy the latest config to the repository
#cp $CONFIG_PATH $REPO_PATH

# Add the file to Git
git add config.rsc

# Commit the changes with a timestamp
git commit -m "Backup config at $(date)"

# Push the changes to the remote repository
git push
