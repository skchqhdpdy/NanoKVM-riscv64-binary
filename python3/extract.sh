docker build -t python3-arm64 .
docker create --name extract python3-arm64
docker cp extract:/python3-arm64.tar.gz ./python3-arm64.tar.gz
docker rm extract
docker image rm python3-arm64