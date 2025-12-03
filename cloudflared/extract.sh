docker build -t cloudflared-riscv64 .
docker create --name extract cloudflared-riscv64
docker cp extract:/cloudflared-riscv64 ./cloudflared
docker rm extract
docker image rm cloudflared-riscv64