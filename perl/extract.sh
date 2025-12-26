docker build -t perl-riscv64 .
docker create --name extract perl-riscv64
docker cp extract:/perl-riscv64.tar.gz ./perl-riscv64.tar.gz
docker rm extract
docker image rm perl-riscv64