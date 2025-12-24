# 1단계: 빌드 환경 설정
FROM debian:bookworm AS builder

RUN apt-get update && apt-get install -y \
    make gcc-riscv64-linux-gnu libc6-dev-riscv64-cross curl tar bc

WORKDIR /build

# lsof 소스 다운로드
RUN curl -L https://github.com/lsof-org/lsof/archive/refs/tags/4.99.3.tar.gz -o lsof.tar.gz \
    && tar -xf lsof.tar.gz --strip-components=1

# 환경 변수 설정
ENV LSOF_CC="riscv64-linux-gnu-gcc -static"
ENV LSOF_AR="riscv64-linux-gnu-ar cr"
ENV LSOF_RANLIB=riscv64-linux-gnu-ranlib

# [수정] Configure 단계에서 필요한 모든 플래그를 미리 정의
RUN LINUX_HAS_STRFTIME=y \
    LSOF_CFGF="-static -DLINUXV=51000 -DHASNORPC_H -DHAS_STRFTIME -D_FILE_OFFSET_BITS=64 -DTCP_ESTABLISHED=1 -DTCP_SYN_SENT=2 -DTCP_SYN_RECV=3 -DTCP_FIN_WAIT1=4 -DTCP_FIN_WAIT2=5 -DTCP_TIME_WAIT=6 -DTCP_CLOSE=7 -DTCP_CLOSE_WAIT=8 -DTCP_LAST_ACK=9 -DTCP_LISTEN=10 -DTCP_CLOSING=11" \
    ./Configure -n linux

# [수정] 빌드 실행
# CFGF 변수가 중요합니다. 여기에 -static과 -DHASNORPC_H가 함께 들어가야 합니다.
RUN make -j$(nproc) \
    CC="riscv64-linux-gnu-gcc -static" \
    DEBUG="-static" \
    CFGF="-static -DLINUXV=51000 -DHASNORPC_H -DHAS_STRFTIME -D_FILE_OFFSET_BITS=64 -DTCP_ESTABLISHED=1 -DTCP_SYN_SENT=2 -DTCP_SYN_RECV=3 -DTCP_FIN_WAIT1=4 -DTCP_FIN_WAIT2=5 -DTCP_TIME_WAIT=6 -DTCP_CLOSE=7 -DTCP_CLOSE_WAIT=8 -DTCP_LAST_ACK=9 -DTCP_LISTEN=10 -DTCP_CLOSING=11"

# 실행 파일 크기 최적화
RUN riscv64-linux-gnu-strip lsof

# 2단계: 결과물 추출
FROM scratch AS exporter
COPY --from=builder /build/lsof /lsof-riscv64
ENTRYPOINT ["/lsof-riscv64"]