docker build -t lsof-riscv64 .
docker create --name extract lsof-riscv64
docker cp extract:/lsof-riscv64 ./lsof
docker rm extract
docker image rm lsof-riscv64