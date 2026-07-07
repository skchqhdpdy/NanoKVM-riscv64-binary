docker build -t openssh-arm64 .
docker create --name extract openssh-arm64
docker cp extract:/openssh-arm64.tar.gz ./openssh-arm64.tar.gz
docker rm extract
docker image rm openssh-arm64