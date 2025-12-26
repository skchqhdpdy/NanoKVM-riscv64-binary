wget https://musl.cc/riscv64-linux-musl-native.tgz
tar -xvf riscv64-linux-musl-native.tgz
mv riscv64-linux-musl-native gcc
cd gcc/bin
ln -sf gcc cc
ln -sf ld ldd
rm riscv64-linux-musl-native.tgz