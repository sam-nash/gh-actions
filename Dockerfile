# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set environment variables
ENV RUNNER_VERSION=2.319.1
ENV RUNNER_URL=https://github.com/sam-nash/gh-actions
ENV RUNNER_TOKEN=A2LWQLQJSI6ZSL63UALLPUDG7AI3A

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a user for the runner
RUN useradd -m runner && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the runner user
USER runner
WORKDIR /home/runner

# Download the latest runner package
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Optional: Validate the hash
RUN echo "3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464  actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c

# Extract the installer
RUN tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]