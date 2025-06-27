FROM ubuntu:22.04 AS base

ENV TZ=America/New_York

# Install dependencies
RUN apt-get update

RUN apt-get install -y curl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]