docker build -t lsof-arm64 .
docker create --name extract lsof-arm64
docker cp extract:/lsof-arm64 ./lsof
docker rm extract
docker image rm lsof-arm64