docker build -t go-riscv64 .
docker create --name extract go-riscv64
docker cp extract:/go-riscv64.tar.gz ./go-riscv64.tar.gz
docker rm extract
docker image rm go-riscv64