# 1. 빌드 및 설정 단계
FROM ubuntu:22.04 AS preparer

RUN apt-get update && apt-get install -y wget xz-utils && apt-get clean

WORKDIR /release
# 바이너리 다운로드 및 압축 해제
RUN wget https://musl.cc/riscv64-linux-musl-native.tgz && \
    tar -xvf riscv64-linux-musl-native.tgz && \
    mv riscv64-linux-musl-native gcc

# 래퍼 스크립트 자동 생성 (빌드 단계에서 처리)
# 1. 사용자용 도구 (gcc/bin) 처리
RUN cd /release/gcc/bin && \
    for tool in addr2line ar as c++filt cpp elfedit gprof ld ld.bfd nm objcopy objdump ranlib readelf size strings strip; do \
        [ -f "$tool" ] && [ ! -f "$tool.real" ] && mv "$tool" "$tool.real" && \
        echo '#!/bin/sh' > "$tool" && \
        echo 'SELF_PATH=$(dirname $(readlink -f "$0"))' >> "$tool" && \
        echo '/lib/ld-musl-riscv64.so.1 "$SELF_PATH/'$tool'.real" "$@"' >> "$tool" && \
        chmod +x "$tool" || true; \
    done

# 2. 컴파일러 내부용 도구 (gcc/riscv64-linux-musl/bin) 처리
RUN cd /release/gcc/riscv64-linux-musl/bin && \
    for tool in ar as ld ld.bfd nm objcopy objdump ranlib readelf strip; do \
        [ -f "$tool" ] && [ ! -f "$tool.real" ] && mv "$tool" "$tool.real" && \
        echo '#!/bin/sh' > "$tool" && \
        echo 'SELF_PATH=$(dirname $(readlink -f "$0"))' >> "$tool" && \
        echo '/lib/ld-musl-riscv64.so.1 "$SELF_PATH/'$tool'.real" "$@"' >> "$tool" && \
        chmod +x "$tool" || true; \
    done

# cc 링크 생성
WORKDIR /release/gcc/bin
RUN ln -sf gcc cc

# 전체를 다시 tar.gz로 압축
WORKDIR /release
RUN tar -czvf gcc-riscv64.tar.gz gcc

# 2. 결과물만 남기는 단계
FROM scratch
COPY --from=preparer /release/gcc-riscv64.tar.gz /gcc-riscv64.tar.gz
ENTRYPOINT ["/gcc-riscv64.tar.gz"]