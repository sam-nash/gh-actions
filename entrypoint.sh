#!/bin/bash

# Fetch the registration token from GitHub API
REGISTRATION_TOKEN=$(curl -s -X POST -H "Authorization: token ${GITHUB_PAT}" \
    https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token | jq -r .token)

# GitHub Runner registration
./config.sh --url https://github.com/${GITHUB_OWNER}/${GITHUB_REPO} --token ${REGISTRATION_TOKEN} --unattended --replace

# Run the runner
./run.sh