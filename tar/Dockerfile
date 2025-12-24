FROM ubuntu:24.04 AS build

RUN apt update && apt install -y \
    wget build-essential gcc-riscv64-linux-gnu g++-riscv64-linux-gnu musl-tools

WORKDIR /src

# tarball 다운로드
RUN wget https://ftp.gnu.org/gnu/tar/tar-1.34.tar.gz && \
    tar xf tar-1.34.tar.gz

WORKDIR /src/tar-1.34

# 정적 빌드
ENV FORCE_UNSAFE_CONFIGURE=1

RUN ./configure \
      --host=riscv64-linux-gnu \
      --prefix=/output \
      --disable-nls \
      CFLAGS="-static" \
      LDFLAGS="-static" && \
    make -j$(nproc) && \
    make install

# export stage
FROM scratch AS export
COPY --from=build /output/bin/tar /tar-riscv64
ENTRYPOINT ["/tar-riscv64"]