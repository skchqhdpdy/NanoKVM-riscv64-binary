wget https://musl.cc/aarch64-linux-musl-native.tgz
tar -xvf aarch64-linux-musl-native.tgz
mv aarch64-linux-musl-native gcc
cd gcc/bin
ln -sf gcc cc
ln -sf ld ldd
rm ../../aarch64-linux-musl-native.tgz