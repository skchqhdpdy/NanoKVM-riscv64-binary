# 1. 빌드 및 설정 단계
FROM ubuntu:22.04 AS preparer

RUN apt-get update && apt-get install -y wget xz-utils && apt-get clean

WORKDIR /release
# 바이너리 다운로드 및 압축 해제
RUN wget https://musl.cc/riscv64-linux-musl-native.tgz && \
    tar -xvf riscv64-linux-musl-native.tgz && \
    mv riscv64-linux-musl-native gcc

# 요청하신 cc 링크 생성 및 환경 설정
WORKDIR /release/gcc/bin
RUN ln -s gcc cc

# 전체를 다시 tar.gz로 압축 (추출하기 편하게)
WORKDIR /release
RUN tar -czvf gcc-riscv64.tar.gz gcc

# 2. 결과물만 남기는 단계
FROM scratch
COPY --from=preparer /release/gcc-riscv64.tar.gz /gcc-riscv64.tar.gz
ENTRYPOINT ["/gcc-riscv64.tar.gz"]