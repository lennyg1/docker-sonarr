# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:arm32v7-focal-version-127ce7ef

ARG VERSION
ARG SONARR_VERSION
ARG DEBIAN_FRONTEND=noninteractive

ENV SONARR_BRANCH="main"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN apt update; apt upgrade -y; apt install -y jq curl sqlite3 libicu66 xmlstarlet mediainfo
RUN mkdir -p /app/sonarr/bin && \
  SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases \
  | jq -r "first(.[] | select(.branch==\"$SONARR_BRANCH\") | .version)"); \
  curl -o \
  /tmp/sonarr.tar.gz -L \
  "https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux-arm.tar.gz" && \
  tar xzf \
  /tmp/sonarr.tar.gz -C \
  /app/sonarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR_BRANCH}" > /app/sonarr/package_info && \
  apt-get clean && \
  rm -rf \
    /app/sonarr/bin/Sonarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /
EXPOSE 8989
VOLUME /config