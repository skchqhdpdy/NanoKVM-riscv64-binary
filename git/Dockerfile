# 1. 빌드 환경 설정
FROM alpine:latest AS builder

RUN apk add --no-cache \
    curl tar make gcc musl-dev bash perl python3 autoconf automake libtool build-base

# RISC-V 64 cross-compiler
RUN wget https://musl.cc/riscv64-linux-musl-cross.tgz \
    && tar -xf riscv64-linux-musl-cross.tgz -C /opt
ENV PATH="/opt/riscv64-linux-musl-cross/bin:${PATH}"
ENV CROSS=riscv64-linux-musl
ENV CC=${CROSS}-gcc
ENV AR=${CROSS}-ar
ENV RANLIB=${CROSS}-ranlib
ENV PREFIX=/opt/riscv64-static

WORKDIR /build

# 2. zlib
RUN curl -L https://zlib.net/zlib-1.3.1.tar.gz | tar -xz \
    && cd zlib-* && ./configure --prefix=$PREFIX --static \
    && make -j$(nproc) && make install

# 3. OpenSSL
RUN curl -L https://www.openssl.org/source/openssl-1.1.1w.tar.gz | tar -xz \
    && cd openssl-* && ./Configure linux64-riscv64 no-shared --prefix=$PREFIX --openssldir=$PREFIX \
    && make -j$(nproc) && make install_sw

# 4. Expat
RUN curl -L https://github.com/libexpat/libexpat/releases/download/R_2_6_0/expat-2.6.0.tar.bz2 | tar -xj \
    && cd expat-* && ./configure --host=$CROSS --prefix=$PREFIX --enable-static --disable-shared \
    && make -j$(nproc) && make install

# 5. Libcurl
RUN curl -L https://curl.se/download/curl-8.6.0.tar.gz | tar -xz \
    && cd curl-* && ./configure --host=$CROSS --prefix=$PREFIX \
    --enable-static --disable-shared --with-openssl=$PREFIX --with-zlib=$PREFIX \
    --without-libpsl --without-libidn2 --disable-ldap --disable-manual \
    && make -j$(nproc) && make install

# 6. Git 빌드
RUN curl -L https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.44.0.tar.gz | tar -xz
WORKDIR /build/git-2.44.0

# 정적 링크를 위한 라이브러리 목록 강제 지정 (순서가 중요함)
# curl -> ssl -> crypto -> zlib -> expat 순서
ENV STATIC_LIBS="-L$PREFIX/lib -lcurl -lssl -lcrypto -lz -lexpat"

# 1) 빌드 실행
RUN make -j$(nproc) \
    CC="${CC}" LD="${CC}" AR="${AR}" RANLIB="${RANLIB}" \
    CFLAGS="-I$PREFIX/include -static" \
    LDFLAGS="-static -no-pie ${STATIC_LIBS}" \
    EXTLIBS="${STATIC_LIBS}" \
    CURL_CONFIG="$PREFIX/bin/curl-config" \
    CURL_LIBCURL="-L$PREFIX/lib -lcurl -lssl -lcrypto -lz" \
    NO_TCLTK=1 NO_GETTEXT=1 NO_ICONV=1 \
    NO_REGEX=NeedsStartEnd NO_INSTALL_HARDLINKS=1 \
    all

# Git은 실행 시 자신의 위치를 기준으로 헬퍼를 찾습니다.
# 'git-remote-https'도 정적 빌드되었으므로 이를 함께 추출해야 합니다.
RUN ${CROSS}-strip /build/git-2.44.0/git && \
    ${CROSS}-strip /build/git-2.44.0/git-remote-http && \
    cp /build/git-2.44.0/git /git-riscv64 && \
    cp /build/git-2.44.0/git-remote-http /git-remote-https-riscv64

# 7. 추출 단계
FROM scratch
COPY --from=builder /git-riscv64 /git-riscv64
COPY --from=builder /git-remote-https-riscv64 /git-remote-https
ENTRYPOINT ["/git-riscv64"]