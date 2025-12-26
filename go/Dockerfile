# 1단계 & 2단계: 빌드 (동일)
FROM golang:1.25-alpine AS bootstrap
RUN apk add --no-cache bash gcc musl-dev curl

WORKDIR /tmp
RUN curl -L https://go.dev/dl/go1.25.5.src.tar.gz | tar -xz

WORKDIR /tmp/go/src
ENV GOROOT_BOOTSTRAP=/usr/local/go GOOS=linux GOARCH=riscv64
RUN ./make.bash

# 3단계: 구조 정리 및 불필요 파일 제거
WORKDIR /tmp/go
RUN rm bin/go bin/gofmt && \
    mv bin/linux_riscv64/* bin/ && \
    rm -rf bin/linux_riscv64 .git/ test/ doc/ api/

# 4단계: tar.gz 압축 파일 생성
FROM alpine AS exporter
RUN apk add --no-cache tar
COPY --from=bootstrap /tmp/go /go
WORKDIR /
# /go-riscv64 폴더를 go-riscv64.tar.gz로 압축
RUN tar -czf /go-riscv64.tar.gz go

# 5단계: 추출을 위한 최소 이미지
FROM scratch
COPY --from=exporter /go-riscv64.tar.gz /go-riscv64.tar.gz
ENTRYPOINT ["/go-riscv64.tar.gz"]