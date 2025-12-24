docker build -t make-riscv64 .
docker create --name extract make-riscv64
docker cp extract:/make-riscv64 ./make
docker rm extract
docker image rm make-riscv64