docker build -t fusermount-riscv64 .
docker create --name extract fusermount-riscv64
docker cp extract:/fusermount-riscv64 ./fusermount
docker cp extract:/fusermount-riscv64 ./fusermount3
docker rm extract
docker image rm fusermount-riscv64