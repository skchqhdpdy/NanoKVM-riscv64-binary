docker build -t gcc-riscv64 .
docker create --name extract gcc-riscv64
docker cp extract:/gcc-riscv64.tar.gz ./gcc-riscv64.tar.gz
docker rm extract
docker image rm gcc-riscv64