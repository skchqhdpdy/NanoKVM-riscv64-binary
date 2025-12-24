docker build -t git-riscv64 .
docker create --name extract git-riscv64
docker cp extract:/git-riscv64 ./git
docker cp extract:/git-remote-https ./git-remote-https
docker rm extract
docker image rm git-riscv64