FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git wget autoconf automake pkg-config \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://musl.cc/riscv64-linux-musl-cross.tgz | tar -xz -C /opt
ENV PATH="/opt/riscv64-linux-musl-cross/bin:${PATH}"
ENV CC=riscv64-linux-musl-gcc
ENV HOST=riscv64-linux-musl

ENV CFLAGS="-I/opt/musl-libs/include -I/opt/musl-libs/include/ncursesw"
ENV LDFLAGS="-L/opt/musl-libs/lib -static"

WORKDIR /build

# --with-fallbacks 옵션을 추가하여 외부 terminfo 파일 없이도 내장된 설정으로 TUI가 작동하게 합니다.
RUN wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.4.tar.gz && \
    tar -xzf ncurses-6.4.tar.gz && \
    cd ncurses-6.4 && \
    ./configure --host=$HOST \
    --prefix=/opt/musl-libs \
    --enable-static --disable-shared \
    --enable-widec \
    --with-fallbacks="xterm,xterm-256color,linux,vt100" \
    --without-cxx --without-cxx-binding --without-ada \
    --without-progs --without-tests --with-normal && \
    make -j$(nproc) && make install

RUN git clone https://github.com/traviscross/mtr.git /build/mtr
WORKDIR /build/mtr

RUN ./bootstrap.sh

RUN ./configure --host=$HOST \
    CC=$CC \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    LIBS="-lncursesw" \
    --without-gtk \
    --without-libcap

RUN make -j$(nproc) && \
    riscv64-linux-musl-strip mtr

FROM scratch
COPY --from=builder /build/mtr/mtr /mtr-riscv64
COPY --from=builder /build/mtr/mtr-packet /mtr-packet-riscv64
ENTRYPOINT ["/mtr-riscv64"]