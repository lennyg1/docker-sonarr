docker buildx prune
docker buildx build . --platform linux/arm/v7 --tag dysje/sonarr-arm32 --push