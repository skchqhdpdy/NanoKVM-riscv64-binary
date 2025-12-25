wget https://musl.cc/riscv64-linux-musl-native.tgz
tar -xvf riscv64-linux-musl-native.tgz
mv riscv64-linux-musl-native gcc
cd gcc/bin
ln -s gcc cc
rm riscv64-linux-musl-native.tgz