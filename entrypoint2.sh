#!/bin/bash
echo "Starting script..."

if [ -n "${ADDITIONAL_PACKAGES}" ]; then
    TO_BE_INSTALLED=$(echo ${ADDITIONAL_PACKAGES} | tr "," " " )
    echo "Installing additional packages: ${TO_BE_INSTALLED}"
    sudo apt-get update && sudo apt-get install -y ${TO_BE_INSTALLED} && sudo apt-get clean
fi

echo "Additional Package check complete..."

registration_url="https://github.com/${GITHUB_OWNER}"
token_url="https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/registration-token"

echo "Checking if GITHUB_TOKEN is set..."

if [ -n "${GITHUB_TOKEN}" ]; then  # This is skipped
    echo "Using given GITHUB_TOKEN"

    if [ -z "${GITHUB_REPOSITORY}" ]; then
        echo "When using GITHUB_TOKEN, the GITHUB_REPOSITORY must be set"
        return
    fi

    registration_url="https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY}"
    export RUNNER_TOKEN=$GITHUB_TOKEN

else # this bliock is executed
    if [ -n "${GITHUB_REPOSITORY}" ]; then
        token_url="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOSITORY}/actions/runners/registration-token"
        registration_url="${registration_url}/${GITHUB_REPOSITORY}"
        echo "Registration URL: ${registration_url}"
    fi

    echo "Requesting token at '${token_url}'"

    payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PAT}" ${token_url})
    echo "payload: ${payload}"
    export RUNNER_TOKEN=$(echo $payload | jq .token --raw-output)
    echo "Runner token: ${RUNNER_TOKEN}"

fi

echo "Starting runner..."

if [ -z "${RUNNER_NAME}" ]; then
    # suffix a time string to the runner name to avoid name conflicts
    RUNNER_NAME=$(hostname)-$(date "+%Y%m%d%H%M%S")
fi

echo "Runner name: ${RUNNER_NAME}"

if [ -z "${RUNNER_LABELS}" ]; then
    RUNNER_LABELS="gha_self_hosted_runner"
fi

if [ -z "${RUNNER_WORKDIR}" ]; then
    RUNNER_WORKDIR="_work"
fi

# ./config.sh \
#     --name "${RUNNER_NAME}" \
#     --token "${RUNNER_TOKEN}" \
#     --url "${registration_url}" \
#     --work "${RUNNER_WORKDIR}" \
#     --labels "${RUNNER_LABELS}" \
#     --unattended \
#     --replace

remove() {
    if [ -n "${GITHUB_TOKEN}" ]; then
        export REMOVE_TOKEN=$GITHUB_TOKEN
    else
        payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PAT}" ${token_url%/registration-token}/remove-token)
        export REMOVE_TOKEN=$(echo $payload | jq .token --raw-output)
    fi

    ./config.sh remove --unattended --token "${REMOVE_TOKEN}"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

# Ensure required environment variables are set
if [ -z "${GITHUB_OWNER}" ] || [ -z "${GITHUB_REPOSITORY}" ] || [ -z "${RUNNER_TOKEN}" ]; then
    echo "Error: GITHUB_OWNER, GITHUB_REPOSITORY, and RUNNER_TOKEN must be set."
    exit 1
fi

# Debugging: Print environment variables
echo "GITHUB_OWNER: ${GITHUB_OWNER}"
echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY}"
echo "RUNNER_TOKEN: ${RUNNER_TOKEN}"
echo "RUNNER_WORKDIR: ${RUNNER_WORKDIR}"
echo "RUNNER_LABELS: ${RUNNER_LABELS}"

export RUNNER_ALLOW_RUNASROOT="1"

# Configure the runner
export AGENT_ALLOW_RUNASROOT="1" 

./config.sh --url https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY} --token ${RUNNER_TOKEN} --name $(hostname) --work ${RUNNER_WORKDIR} --labels ${RUNNER_LABELS} --unattended --replace

# Check if the configuration was successful
if [ $? -ne 0 ]; then
    echo "Error: Runner configuration failed."
    exit 1
fi
    
echo "Starting runner..."
./runsvc2.sh "$*" &

wait $!
