FROM ubuntu:22.04 AS base
ARG GITHUB_RUNNER_VERSION=2.325.0
ARG DEBIAN_FRONTEND=noninteractive

ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}
ENV GITHUB_RUNNER_VERSION=${GITHUB_RUNNER_VERSION}
ENV TZ=America/New_York

# Install dependencies
RUN apt-get update

RUN apt-get install -y \
    ca-certificates \
    curl \
    dbus-user-session \
    fuse-overlayfs \
    gnupg2 \
    iproute2 \
    iptables \
    jq \
    kmod \
    lsb-release \
    mlocate \
    slirp4netns \
    software-properties-common \
    sudo \
    uidmap

RUN rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list

RUN apt-get update

RUN apt-get install -y --no-install-recommends \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli

RUN apt-get install -y docker-ce-rootless-extras=5:25.0.3-1~ubuntu.22.04~jammy --allow-downgrades

RUN mkdir /runner
WORKDIR /runner

RUN curl -o actions-runner.tar.gz -fsSL https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz
RUN tar xzf ./actions-runner.tar.gz
RUN rm -rf ./actions-runner.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /run/user/1001

RUN groupadd --gid 1001 runner
RUN useradd --uid 1001 --gid runner --shell /bin/bash --create-home runner
RUN chown -R runner:runner /runner /entrypoint.sh /run/user/1001
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER runner
ENV USER=runner
ENV HOME=/home/runner

# Set up environment variables for rootless Docker
ENV PATH=/home/runner/bin:$PATH
ENV DOCKER_HOST=unix:///run/user/1001/docker.sock

# Install Docker rootless
RUN dockerd-rootless-setuptool.sh install --skip-iptables

ENTRYPOINT [ "/entrypoint.sh" ]
