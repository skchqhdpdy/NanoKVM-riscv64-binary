# 1. 빌드 스테이지 (최신 Go Alpine 이미지 사용)
FROM golang:alpine AS builder

# git 설치 (rclone 소스 다운로드용)
RUN apk add --no-cache git

# rclone 공식 레포지토리 클론
# 특정 버전을 원한다면 git clone --branch v1.65.0 처럼 태그를 지정할 수 있습니다.
RUN git clone https://github.com/rclone/rclone.git /build
WORKDIR /build

ARG GOOS=linux
ARG GOARCH=arm64
# =========================================================

# Go 크로스 컴파일 및 정적 빌드 실행
# CGO_ENABLED=0 : C 라이브러리(glibc 등) 의존성을 완전히 제거하여 완벽한 단일 실행 파일 생성
# -ldflags="-s -w" : 디버깅 심볼을 제거하여 바이너리 용량을 대폭 최적화
# -trimpath : 빌드 환경의 절대 경로가 바이너리에 포함되지 않도록 정리
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${GOARCH} \
    go build -trimpath -ldflags="-s -w" -o /rclone-arm64

# 2. 추출 스테이지 (가장 가벼운 scratch 이미지 사용하여 빌드 찌꺼기 제거)
FROM scratch
# 빌드된 단일 바이너리만 빈 컨테이너로 복사
COPY --from=builder /rclone-arm64 /rclone-arm64
ENTRYPOINT ["/rclone-arm64"]