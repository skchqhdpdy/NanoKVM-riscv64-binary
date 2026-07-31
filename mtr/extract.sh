docker build -t mtr-riscv64 .
docker create --name extract mtr-riscv64
docker cp extract:/mtr-riscv64 ./mtr
docker cp extract:/mtr-packet-riscv64 ./mtr-packet
docker rm extract
docker image rm mtr-riscv64