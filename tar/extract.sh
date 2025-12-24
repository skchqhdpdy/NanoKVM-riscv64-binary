docker build -t tar-riscv64 .
docker create --name extract tar-riscv64
docker cp extract:/tar-riscv64 ./tar
docker rm extract
docker image rm tar-riscv64