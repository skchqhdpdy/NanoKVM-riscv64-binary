docker build -t fusermount-arm64 .
docker create --name extract fusermount-arm64
docker cp extract:/fusermount-arm64 ./fusermount
docker cp extract:/fusermount-arm64 ./fusermount3
docker rm extract
docker image rm fusermount-arm64