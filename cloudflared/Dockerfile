# -------------------------------
# Stage 1: Builder
# -------------------------------
FROM golang:1.25 AS builder

# 필수 패키지 설치
RUN apt-get update && apt-get install -y git make

WORKDIR /src

# 소스 코드 클론
RUN git clone https://github.com/cloudflare/cloudflared .

# Makefile에서 GOOS/GOARCH 하드코딩
RUN sed -i 's/GOOS=$(TARGET_OS) GOARCH=$(TARGET_ARCH)/GOOS=linux GOARCH=riscv64/' Makefile

# 빌드
RUN make cloudflared

# -------------------------------
# Stage 2: Minimal image
# -------------------------------
FROM scratch
COPY --from=builder /src/cloudflared /cloudflared-riscv64
ENTRYPOINT ["/cloudflared-riscv64"]