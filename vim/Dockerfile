# 1. 빌드 환경: Debian 12 (Bookworm)
FROM debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 2. 크로스 컴파일러 및 빌드 도구 설치 (Debian 공식 글로벌 CDN 사용)
RUN apt-get update && apt-get install -y \
    gcc-riscv64-linux-gnu \
    build-essential \
    wget \
    git \
    tar \
    make \
    ncurses-bin

WORKDIR /build

# 3. Ncurses 소스 크로스 컴파일 (터미널 정보 내장)
RUN wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.4.tar.gz && \
    tar -xzf ncurses-6.4.tar.gz && \
    cd ncurses-6.4 && \
    ./configure \
        --build=x86_64-linux-gnu \
        --host=riscv64-linux-gnu \
        --prefix=/opt/riscv64 \
        --without-shared \
        --without-cxx \
        --without-cxx-binding \
        --without-ada \
        --without-progs \
        --without-tests \
        --enable-termcap \
        --with-fallbacks=xterm,xterm-256color,vt100,linux,ansi && \
    make -j$(nproc) && \
    make install

# 4. Vim 소스코드 다운로드
RUN git clone --depth 1 https://github.com/vim/vim.git /build/vim

WORKDIR /build/vim/src

# 5. 크로스 컴파일 런타임 테스트 캐시 생성
RUN echo "vim_cv_bcopy_handles_overlap=yes" > config.cache && \
    echo "vim_cv_memmove_handles_overlap=yes" >> config.cache && \
    echo "vim_cv_stat_ignores_slash=no" >> config.cache && \
    echo "vim_cv_terminfo=yes" >> config.cache && \
    echo "vim_cv_toupper_broken=no" >> config.cache && \
    echo "vim_cv_tty_group=world" >> config.cache && \
    echo "vim_cv_tgetent=zero" >> config.cache && \
    echo "vim_cv_getcwd_broken=no" >> config.cache

# 6. 컴파일러 환경 변수 설정
ENV CC=riscv64-linux-gnu-gcc
ENV LDFLAGS="-static -L/opt/riscv64/lib"
ENV CPPFLAGS="-I/opt/riscv64/include -I/opt/riscv64/include/ncurses"
ENV CFLAGS="-I/opt/riscv64/include -I/opt/riscv64/include/ncurses"

# 7. Vim 크로스 컴파일 설정
RUN ./configure \
    --build=x86_64-linux-gnu \
    --host=riscv64-linux-gnu \
    --with-tlib=ncurses \
    --with-features=huge \
    --enable-gui=no \
    --without-x \
    --disable-nls \
    --disable-pythoninterp \
    --disable-perlinterp \
    --disable-rubyinterp \
    --disable-luainterp \
    --cache-file=config.cache

# 8. 빌드 및 레거시 헤더 충돌 우회
RUN make -j$(nproc) || ( \
    sed -i '/tgoto/d' auto/osdef.h && \
    sed -i '/tgetent/d' auto/osdef.h && \
    sed -i '/tgetflag/d' auto/osdef.h && \
    sed -i '/tgetnum/d' auto/osdef.h && \
    sed -i '/tputs/d' auto/osdef.h && \
    make -j$(nproc) \
    )

# 9. 용량 최적화 (strip)
RUN riscv64-linux-gnu-strip vim

# 10. 추출용 빈 이미지
FROM scratch
COPY --from=builder /build/vim/src/vim /vim-riscv64
CMD ["/vim-riscv64"]