docker build -t make-arm64 .
docker create --name extract make-arm64
docker cp extract:/make-arm64 ./make
docker rm extract
docker image rm make-arm64