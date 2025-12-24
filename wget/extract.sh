docker build -t wget-riscv64 .
docker create --name extract wget-riscv64
docker cp extract:/wget-riscv64 ./wget
docker rm extract
docker image rm wget-riscv64