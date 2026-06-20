docker build -t fastfetch-riscv64 .
docker create --name extract fastfetch-riscv64
docker cp extract:/fastfetch-riscv64 ./fastfetch
docker rm extract
docker image rm fastfetch-riscv64