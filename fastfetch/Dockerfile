# 빌드 환경: x64 우분투에서 ARM64 바이너리 크로스 컴파일
FROM ubuntu:22.04 AS builder

# 빌드에 필요한 도구 및 arm64(aarch64) 크로스 컴파일러 설치
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# fastfetch 소스 코드 가져오기
WORKDIR /src
RUN git clone https://github.com/fastfetch-cli/fastfetch.git .

# 빌드 디렉토리 생성 및 크로스 컴파일 설정
WORKDIR /src/build
RUN cmake .. \
    -G Ninja \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
    -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_FLASHFETCH=OFF \
    -DSET_TINFO=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static -pthread"

# 컴파일 진행
RUN ninja fastfetch

# 최종 바이너리 위치 지정
RUN cp /src/build/fastfetch /fastfetch-arm64

# 실행 환경 (최소화 및 단일 바이너리만 포함)
FROM scratch
COPY --from=builder /fastfetch-arm64 /fastfetch-arm64
ENTRYPOINT ["/fastfetch-arm64"]