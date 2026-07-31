docker build -t mtr-arm64 .
docker create --name extract mtr-arm64
docker cp extract:/mtr-arm64 ./mtr
docker cp extract:/mtr-packet-arm64 ./mtr-packet
docker rm extract
docker image rm mtr-arm64