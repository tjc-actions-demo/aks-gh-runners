FROM ubuntu:22.04
ARG GITHUB_RUNNER_VERSION=2.325.0
ARG DEBIAN_FRONTEND=noninteractive

ENV GITHUB_RUNNER_VERSION=${GITHUB_RUNNER_VERSION}
ENV TZ=America/New_York

RUN echo "dash dash/sh boolean false" | debconf-set-selections

RUN apt update
RUN apt upgrade -y
RUN apt install -y \
    ca-certificates \
    curl \
    git \
    libicu-dev \
    jq

RUN apt clean

RUN mkdir /runner
WORKDIR /runner

RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz
RUN tar xzf ./actions-runner.tar.gz
RUN rm -rf ./actions-runner.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN groupadd --gid 1001 runner && useradd --uid 1001 --gid runner --shell /bin/bash --create-home runner
RUN chown -R runner:runner /runner /entrypoint.sh

USER runner

ENTRYPOINT [ "/entrypoint.sh" ]
