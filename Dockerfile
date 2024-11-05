FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Use a different mirror for the Ubuntu repository
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://us.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl sudo jq iputils-ping zip libssl-dev libcurl4-gnutls-dev zlib1g-dev gettext make build-essential python3-pip wget cmake clang perl psmisc software-properties-common git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER root

RUN apt-get update && apt install wget -y
RUN GITHUB_RUNNER_VERSION=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | jq -r '.tag_name[1:]') \
    && curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz && rm -f actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz \
    && sudo ./bin/installdependencies.sh \
    && sed -i '3,9d' ./config.sh \
    && sed -i '3,8d' ./run.sh

# RUN  /root/bin/installdependencies.sh

COPY entrypoint.sh runsvc.sh ./

RUN chmod +x ./entrypoint.sh ./runsvc.sh

ENTRYPOINT ["./entrypoint.sh"]