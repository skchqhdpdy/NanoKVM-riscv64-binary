docker build -t wget-arm64 .
docker create --name extract wget-arm64
docker cp extract:/wget-arm64 ./wget
docker rm extract
docker image rm wget-arm64