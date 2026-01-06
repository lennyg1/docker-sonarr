docker run -d \
  --name=sonarr \
  -e PUID=100 \
  -e PGID=500 \
  -e TZ=Etc/UTC \
  -p 8989:8989 \
  -v /path/to/data:/config \
  -v /path/to/media:/media \
  --restart unless-stopped