# 기본 amd64 데비안 이미지 사용 (Pixel arm64 빌드용)
FROM debian:12

ARG PY_VERSION=3.14.4
ARG PY_MAJOR_MINOR=3.14

# 필수 빌드 도구 설치
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential wget unzip zlib1g-dev libssl-dev libffi-dev pkg-config perl

WORKDIR /build

# 1. 안드로이드 NDK 다운로드
RUN wget https://dl.google.com/android/repository/android-ndk-r26b-linux.zip && \
    unzip android-ndk-r26b-linux.zip

# 2. 파이썬 소스코드 다운로드 (변수 적용)
RUN wget https://www.python.org/ftp/python/${PY_VERSION}/Python-${PY_VERSION}.tgz && \
    tar -xf Python-${PY_VERSION}.tgz

# 3. OpenSSL 1.1.1w 소스코드 다운로드
RUN wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz && \
    tar -xzf openssl-1.1.1w.tar.gz

# 4. LibFFI 3.4.4 소스코드 다운로드
RUN wget https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz && \
    tar -xzf libffi-3.4.4.tar.gz

# ==========================================
# [STEP 1] Host(amd64)용 빌드 파이썬 생성 
# ==========================================
WORKDIR /build/Python-${PY_VERSION}
RUN ./configure && make -j$(nproc) && make install && make clean

# ==========================================
# 공통 환경 변수 세팅 (Android NDK 및 타겟)
# ==========================================
ENV ANDROID_NDK_ROOT=/build/android-ndk-r26b
ENV ANDROID_NDK_HOME=/build/android-ndk-r26b
ENV TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
ENV PATH="$TOOLCHAIN/bin:$PATH"
ENV TARGET=aarch64-linux-android
ENV API=24

# ==========================================
# [STEP 1.5] Target(arm64 Android)용 OpenSSL 빌드
# ==========================================
WORKDIR /build/openssl-1.1.1w
RUN ./Configure android-arm64 -D__ANDROID_API__=$API no-shared --prefix=/opt/openssl-arm64 --openssldir=/opt/openssl-arm64 && \
    make -j$(nproc) && make install_sw

# ==========================================
# [STEP 1.7] Target(arm64 Android)용 LibFFI 빌드
# ==========================================
WORKDIR /build/libffi-3.4.4
RUN CC=$TOOLCHAIN/bin/${TARGET}${API}-clang \
    CXX=$TOOLCHAIN/bin/${TARGET}${API}-clang++ \
    AR=$TOOLCHAIN/bin/llvm-ar \
    RANLIB=$TOOLCHAIN/bin/llvm-ranlib \
    CFLAGS="-Wno-error=implicit-function-declaration" \
    ./configure \
    --host=$TARGET \
    --build=x86_64-linux-gnu \
    --prefix=/opt/libffi-arm64 \
    --disable-shared \
    && make -j$(nproc) && make install

# ==========================================
# [STEP 2] Target(arm64 Android)용 파이썬 크로스 컴파일
# ==========================================
WORKDIR /build/Python-${PY_VERSION}

ENV CFLAGS="-I/opt/openssl-arm64/include -I/opt/libffi-arm64/include"
ENV LDFLAGS="-L/opt/openssl-arm64/lib -L/opt/libffi-arm64/lib -Wl,-rpath,'\$\$ORIGIN/../lib'"
ENV PKG_CONFIG_PATH="/opt/openssl-arm64/lib/pkgconfig:/opt/libffi-arm64/lib/pkgconfig"

RUN CC=$TOOLCHAIN/bin/${TARGET}${API}-clang \
    CXX=$TOOLCHAIN/bin/${TARGET}${API}-clang++ \
    AR=$TOOLCHAIN/bin/llvm-ar \
    READELF=$TOOLCHAIN/bin/llvm-readelf \
    RANLIB=$TOOLCHAIN/bin/llvm-ranlib \
    ./configure \
    --host=$TARGET \
    --build=x86_64-linux-gnu \
    --prefix=/python3-arm64 \
    --disable-ipv6 \
    --enable-shared \
    --with-build-python=/usr/local/bin/python3 \
    --with-openssl=/opt/openssl-arm64 \
    ac_cv_buggy_getaddrinfo=no \
    ac_cv_file__dev_ptmx=yes \
    ac_cv_file__dev_ptc=no \
    && make -j$(nproc) \
    && make install

# ==========================================
# [STEP 2.5] Target(arm64 Android)용 pip 수동 강제 설치
# ==========================================
WORKDIR /build
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    /usr/local/bin/python3 get-pip.py --prefix=/python3-arm64

# ==========================================
# [STEP 3] 불필요 파일 제거 및 결과물 압축
# ==========================================
WORKDIR /
# __pycache__ 및 test 폴더를 삭제하여 용량을 최적화하고 최고 압축률(-9)로 패키징합니다.
RUN find /python3-arm64 -name "__pycache__" -type d -exec rm -rf {} + \
    && rm -rf /python3-arm64/lib/python${PY_MAJOR_MINOR}/test \
    && tar -I 'gzip -9' -cvf /python3-arm64.tar.gz /python3-arm64

ENTRYPOINT ["/python3-arm64.tar.gz"]