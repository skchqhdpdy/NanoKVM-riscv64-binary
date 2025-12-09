docker build -t perl-riscv64 .
docker create --name extract perl-riscv64
docker cp perl-riscv64/usr/local/bin/perl ./perl
docker image rm perl-riscv64