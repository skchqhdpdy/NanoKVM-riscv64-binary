docker build -t aha-arm64 .
docker create --name extract aha-arm64
docker cp extract:/aha-arm64 ./aha
docker rm extract
docker image rm aha-arm64