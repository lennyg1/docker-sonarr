#!/bin/sh
set -e

# default PUID/PGID expected as env vars (already documented in Dockerfile)
: "${PUID:=1000}"
: "${PGID:=1000}"

# create group if missing
if ! getent group radarr >/dev/null 2>&1; then
  if getent group "${PGID}" >/dev/null 2>&1; then
    # group with PGID exists, reuse its name
    EXIST_NAME=$(getent group "${PGID}" | cut -d: -f1)
    groupname="${EXIST_NAME}"
  else
    addgroup --gid "${PGID}" radarr 2>/dev/null || groupadd -g "${PGID}" radarr
  fi
fi

# create user if missing
if ! id -u radarr >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" --uid "${PUID}" --gid "${PGID}" --home /config radarr 2>/dev/null || \
    useradd -u "${PUID}" -g "${PGID}" -M -s /usr/sbin/nologin -d /config radarr
fi

# ensure permissions
chown -R "${PUID}:${PGID}" /config /app/radarr || true

# run as radarr using gosu if present, fallback to su
if command -v gosu >/dev/null 2>&1; then
  exec gosu radarr "$@"
else
  exec su -s /bin/sh radarr -c "$*"
fi