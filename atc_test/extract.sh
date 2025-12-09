# === 사용자 정의: 설치 경로 ===
INSTALL_DIR=/root/tools/autoconf
docker build --build-arg INSTALL_DIR=$INSTALL_DIR -t autoconf-riscv64 .
docker create --name extract autoconf-riscv64
docker cp extract:$INSTALL_DIR ./autoconf
docker rm extract
docker image rm autoconf-riscv64