FROM python:3.9-slim

# Clear the APT cache and update package lists
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    bash 

# Create a user
RUN useradd -m runner

WORKDIR /home/runner

# Download and install GitHub Actions runner
RUN curl -o actions-runner-linux-x64-2.285.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.285.0/actions-runner-linux-x64-2.285.0.tar.gz \
    && tar xzf ./actions-runner-linux-x64-2.285.0.tar.gz \
    && rm ./actions-runner-linux-x64-2.285.0.tar.gz

# Copy the entrypoint script
COPY entrypoint.sh /home/runner/entrypoint.sh