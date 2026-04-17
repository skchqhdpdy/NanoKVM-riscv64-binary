docker build -t cloudflared-arm64 .
docker create --name extract cloudflared-arm64
docker cp extract:/cloudflared-arm64 ./cloudflared
docker rm extract
docker image rm cloudflared-arm64