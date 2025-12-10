docker build -t aha-riscv64 .
docker create --name extract aha-riscv64
docker cp extract:/aha-riscv64 ./aha
docker rm extract
docker image rm aha-riscv64