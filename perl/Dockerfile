FROM ubuntu:24.04

RUN apt update && apt install -y \
    wget build-essential make \
    gcc-riscv64-linux-gnu g++-riscv64-linux-gnu

WORKDIR /build
RUN wget https://www.cpan.org/src/5.0/perl-5.40.0.tar.gz && \
    tar xzf perl-5.40.0.tar.gz

WORKDIR /build/perl-5.40.0

RUN ./Configure -des \
      -Dprefix=/opt/perl \
      -Dcc=riscv64-linux-gnu-gcc \
      -Duseshrplib=no \
      -Doptimize="-O2" \
      -Accflags="-static" \
      -Aldflags="-static" \
      -Dusecrosscompile \
      -Dtargetarch=riscv64 \
      -Dtargethost=none \
      -Dtargetrun=/bin/true

RUN make -j$(nproc)
RUN make install