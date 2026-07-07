docker build -t fastfetch-arm64 .
docker create --name extract fastfetch-arm64
docker cp extract:/fastfetch-arm64 ./fastfetch
docker rm extract
docker image rm fastfetch-arm64