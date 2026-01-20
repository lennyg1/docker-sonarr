FROM ubuntu:22.04

ARG SONARR_BRANCH="develop"
ARG DEBIAN_FRONTEND=noninteractive

ENV SONARR_BRANCH="${SONARR_BRANCH}"
ENV XDG_CONFIG_HOME="/app/config"
ENV PUID=1001
ENV PGID=1001
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y ca-certificates tzdata curl jq sqlite3 xmlstarlet mediainfo gnupg2 apt-utils adduser coreutils && \
    # pick the newest libicu package available on this platform
    LIBICU="$(apt-cache pkgnames | grep -E '^libicu[0-9]+' | sort -V | tail -n1)" && \
    if [ -n "$LIBICU" ]; then apt-get install -y "$LIBICU"; fi && \
    # install gosu for safe user switch at runtime
    curl -fsSL -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.19/gosu-armhf" && \
    chmod +x /usr/local/bin/gosu && gosu nobody true || true && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

RUN mkdir -p /app/sonarr/bin /app/config && \
  SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases \
  | jq -r "first(.[] | select(.branch==\"$SONARR_BRANCH\") | .version)"); \
  curl -o /tmp/sonarr.tar.gz -L "https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux-arm.tar.gz" && \
  tar xzf /tmp/sonarr.tar.gz -C /app/sonarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR_BRANCH}" > /app/sonarr/package_info && \
  rm -rf /tmp/* /app/sonarr/bin/Sonarr.Update

COPY root/ /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && \
  ln -s /app/config /config

EXPOSE 8989
VOLUME /config

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/app/sonarr/bin/Sonarr", "-nobrowser"]