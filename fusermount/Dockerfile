# ==============================================================================
# 안드로이드(aarch64)용 정적 fusermount 단일 바이너리 빌드 Dockerfile
# ==============================================================================
FROM debian:bullseye-slim AS builder

# 필수 빌드 도구 패키지 설치
RUN apt-get update && \
    apt-get install -y wget curl make gcc tar xz-utils

# musl.cc 크로스 컴파일러 세팅 (안드로이드 환경 최적화)
RUN wget https://musl.cc/aarch64-linux-musl-cross.tgz && \
    tar -xzf aarch64-linux-musl-cross.tgz -C /opt

ENV PATH="/opt/aarch64-linux-musl-cross/bin:${PATH}"

# 안정성이 검증된 FUSE 2.9.9 다운로드
WORKDIR /
RUN curl -L https://github.com/libfuse/libfuse/releases/download/fuse-2.9.9/fuse-2.9.9.tar.gz | \
    tar -xz
WORKDIR /fuse-2.9.9

# config.h 및 기본 헤더 생성을 위해 configure만 실행
RUN CC="aarch64-linux-musl-gcc" \
    ./configure \
    --host=aarch64-linux-musl

# ★ [추가된 핵심] -no-pie 옵션을 추가하여 순수 정적 실행 파일(Executable)로 강제 변환
RUN aarch64-linux-musl-gcc \
    -O2 -static -no-pie \
    -I./include -I./lib \
    -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE \
    util/fusermount.c util/mount_util.c \
    -o util/fusermount

# 용량 축소를 위한 strip 적용
RUN aarch64-linux-musl-strip util/fusermount

# --- [추출 단계] ---
FROM scratch
COPY --from=builder /fuse-2.9.9/util/fusermount /fusermount-arm64
ENTRYPOINT ["/fusermount-arm64"]