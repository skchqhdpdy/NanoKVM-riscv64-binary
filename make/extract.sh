docker build -t make-riscv64-static .
docker create --name extract make-riscv64-static
docker cp extract:/make-riscv64 ./make-riscv64
docker rm extract
docker image rm make-riscv64-static