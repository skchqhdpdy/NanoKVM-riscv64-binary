docker build -t vim-arm64 .
docker create --name extract vim-arm64
docker cp extract:/vim-arm64 ./vim
docker rm extract
docker image rm vim-arm64