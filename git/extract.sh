docker build -t git-arm64 .
docker create --name extract git-arm64
docker cp extract:/git-arm64 ./git
docker cp extract:/git-remote-https ./git-remote-https
docker rm extract
docker image rm git-arm64