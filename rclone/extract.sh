docker build -t rclone-riscv64 .
docker create --name extract rclone-riscv64
docker cp extract:/rclone-riscv64 ./rclone
docker rm extract
docker image rm rclone-riscv64