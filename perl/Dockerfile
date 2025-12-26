FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential wget gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu libc6-dev-riscv64-cross \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN wget https://www.cpan.org/src/5.0/perl-5.36.0.tar.gz && \
    wget https://github.com/arsv/perl-cross/releases/download/1.4.1/perl-cross-1.4.1.tar.gz && \
    tar -xzf perl-5.36.0.tar.gz && tar -xzf perl-cross-1.4.1.tar.gz

WORKDIR /build/perl-5.36.0
RUN cp -rf ../perl-cross-1.4.1/* .

# 에러가 났던 -Dinstallusrbinperl=n 옵션은 제거하는 것이 안전합니다.
RUN CC=riscv64-linux-gnu-gcc ./configure \
    --target=riscv64-linux-gnu \
    --prefix=/perl \
    -Dstatic -Dldflags="-static" -Dccflags="-static" --no-dynaloader

RUN make -j$(nproc) && make install
RUN riscv64-linux-gnu-strip /perl/bin/perl

# 2. 래퍼 스크립트 수정 (확인된 경로 반영)
WORKDIR /perl/bin
RUN mv perl perl.real && \
    echo '#!/bin/sh' > perl && \
    echo 'SELF_PATH=$(dirname $(readlink -f "$0"))' >> perl && \
    echo 'P=$(dirname "$SELF_PATH")' >> perl && \
    # 실제 확인된 perl5 경로를 PERL5LIB에 추가
    echo 'export PERL5LIB="$P/lib/perl5/5.36.0:$P/lib/perl5/5.36.0/riscv64-linux"' >> perl && \
    echo 'exec "$SELF_PATH/perl.real" "$@"' >> perl && \
    chmod +x perl

# 3. 압축 (추출 편의를 위해 /perl 폴더 자체를 압축)
RUN tar -czvf /perl-riscv64.tar.gz -C / perl

FROM scratch
COPY --from=builder /perl-riscv64.tar.gz /
ENTRYPOINT ["/perl-riscv64.tar.gz"]