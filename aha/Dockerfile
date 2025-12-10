# Builder
FROM ubuntu:22.04 AS builder
RUN apt-get update && \
    apt-get install -y wget build-essential gcc-riscv64-linux-gnu
RUN wget https://raw.githubusercontent.com/theZiz/aha/refs/heads/master/aha.c
RUN riscv64-linux-gnu-gcc -O2 -static -Wno-format-truncation -o /aha-riscv64 aha.c

# Final minimal image
FROM scratch
COPY --from=builder /aha-riscv64 /aha-riscv64
ENTRYPOINT ["/aha-riscv64"]