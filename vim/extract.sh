docker build -t vim-riscv64 .
docker create --name extract vim-riscv64
docker cp extract:/vim-riscv64 ./vim
docker rm extract
docker image rm vim-riscv64