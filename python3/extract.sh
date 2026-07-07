docker build -t python3-riscv64 .
docker create --name extract python3-riscv64
docker cp extract:/python3-riscv64.tar.gz ./python3-riscv64.tar.gz
docker rm extract
docker image rm python3-riscv64