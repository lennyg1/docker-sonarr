#!/bin/sh
set -e

# default PUID/PGID expected as env vars (already documented in Dockerfile)
: "${PUID:=1000}"
: "${PGID:=1000}"

# create group if missing
if ! getent group sonarr >/dev/null 2>&1; then
  if getent group "${PGID}" >/dev/null 2>&1; then
    # group with PGID exists, reuse its name
    EXIST_NAME=$(getent group "${PGID}" | cut -d: -f1)
    groupname="${EXIST_NAME}"
  else
    addgroup --gid "${PGID}" sonarr 2>/dev/null || groupadd -g "${PGID}" sonarr
  fi
fi

# create user if missing
if ! id -u sonarr >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" --uid "${PUID}" --gid "${PGID}" --home /app/config sonarr 2>/dev/null || \
    useradd -u "${PUID}" -g "${PGID}" -M -s /usr/sbin/nologin -d /app/config sonarr
fi

# ensure permissions
chown -R "${PUID}:${PGID}" /app/config /app/sonarr || true

# run as sonarr using gosu if present, fallback to su
if command -v gosu >/dev/null 2>&1; then
  exec gosu sonarr "$@"
else
  exec su -s /bin/sh sonarr -c "$*"
fi