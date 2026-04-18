# 모든 스테이지에서 공유할 전역 변수를 가장 먼저 선언
ARG SSH_VER=9.7p1

# QEMU 없이 amd64 환경에서 고속 크로스 컴파일
FROM debian:bullseye-slim AS builder

ARG SSH_VER

# 필수 패키지 설치
RUN apt-get update && \
    apt-get install -y wget curl make bzip2 tar xz-utils perl

# musl.cc 크로스 컴파일러 세팅
RUN wget https://musl.cc/aarch64-linux-musl-cross.tgz && \
    tar -xzf aarch64-linux-musl-cross.tgz -C /opt

ENV PATH="/opt/aarch64-linux-musl-cross/bin:${PATH}"

# 1. Zlib 정적 크로스 컴파일
WORKDIR /
RUN curl -L https://zlib.net/fossils/zlib-1.3.1.tar.gz | tar -xz
WORKDIR /zlib-1.3.1
RUN CC="aarch64-linux-musl-gcc" AR="aarch64-linux-musl-ar" RANLIB="aarch64-linux-musl-ranlib" \
    ./configure --prefix=/opt/musl-deps --static && \
    make -j$(nproc) && make install

# 2. OpenSSL 정적 크로스 컴파일
WORKDIR /
RUN wget https://www.openssl.org/source/openssl-3.0.13.tar.gz && tar -xzf openssl-3.0.13.tar.gz
WORKDIR /openssl-3.0.13
RUN ./Configure linux-aarch64 no-shared no-async --prefix=/opt/musl-deps --cross-compile-prefix=aarch64-linux-musl- && \
    make -j$(nproc) && make install

# 3. OpenSSH 다운로드 및 마개조
WORKDIR /
RUN wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${SSH_VER}.tar.gz && \
    tar -xzf openssh-${SSH_VER}.tar.gz

WORKDIR /openssh-${SSH_VER}

# ==========================================
# 💡 핵심 수정: Segfault 원인 제거 및 그룹 가로채기 추가
# ==========================================
RUN cat << 'EOF' > android_pwd.c
#include <stdio.h>
#include <pwd.h>
#include <grp.h>
#include <string.h>
#include <stdlib.h>

#define PWD_FILE "/data/root/etc/passwd"

static struct passwd pw_ret;
static struct group gr_ret;
static char line_buf[256];
static char shell_buf[64];
static char *gr_mem[2] = { "root", NULL };

struct passwd* __wrap_getpwnam(const char *name) {
    if (!name) return NULL;
    if (strcmp(name, "sshd") == 0) {
        pw_ret.pw_name = "sshd"; pw_ret.pw_passwd = "*";
        pw_ret.pw_uid = 2000; pw_ret.pw_gid = 2000;
        pw_ret.pw_gecos = "sshd privsep"; // <-- Segfault 핵심 원인 방어 (NULL 금지)
        pw_ret.pw_dir = "/data/local/tmp/empty"; pw_ret.pw_shell = "/system/bin/false";
        return &pw_ret;
    }
    
    FILE *f = fopen(PWD_FILE, "r");
    if (!f) return NULL;
    
    while (fgets(line_buf, sizeof(line_buf), f)) {
        char *uname = strtok(line_buf, ":");
        char *pwd = strtok(NULL, ":");
        char *uid_s = strtok(NULL, ":");
        char *gid_s = strtok(NULL, ":");
        char *gecos = strtok(NULL, ":");
        char *dir = strtok(NULL, ":");
        char *shell = strtok(NULL, ":\n");

        if (!uname || !pwd || !uid_s || !gid_s || !dir || !shell) continue;

        if (strcmp(uname, name) == 0) {
            pw_ret.pw_name = uname;
            pw_ret.pw_passwd = pwd;
            pw_ret.pw_uid = atoi(uid_s);
            pw_ret.pw_gid = atoi(gid_s);
            pw_ret.pw_gecos = gecos ? gecos : "";
            pw_ret.pw_dir = dir;
            strncpy(shell_buf, shell, sizeof(shell_buf)-1);
            pw_ret.pw_shell = shell_buf;
            fclose(f);
            return &pw_ret;
        }
    }
    fclose(f);
    return NULL;
}

struct passwd* __wrap_getpwuid(uid_t uid) {
    if (uid == 2000) return __wrap_getpwnam("sshd");
    
    FILE *f = fopen(PWD_FILE, "r");
    if (!f) return NULL;
    
    while (fgets(line_buf, sizeof(line_buf), f)) {
        char *uname = strtok(line_buf, ":");
        char *pwd = strtok(NULL, ":");
        char *uid_s = strtok(NULL, ":");
        char *gid_s = strtok(NULL, ":");
        char *gecos = strtok(NULL, ":");
        char *dir = strtok(NULL, ":");
        char *shell = strtok(NULL, ":\n");

        if (!uname || !pwd || !uid_s || !gid_s || !dir || !shell) continue;

        if (atoi(uid_s) == uid) {
            pw_ret.pw_name = uname;
            pw_ret.pw_passwd = pwd;
            pw_ret.pw_uid = atoi(uid_s);
            pw_ret.pw_gid = atoi(gid_s);
            pw_ret.pw_gecos = gecos ? gecos : "";
            pw_ret.pw_dir = dir;
            strncpy(shell_buf, shell, sizeof(shell_buf)-1);
            pw_ret.pw_shell = shell_buf;
            fclose(f);
            return &pw_ret;
        }
    }
    fclose(f);
    return NULL;
}

// 그룹 조회 함수 가로채기 (libc 충돌 완전 차단)
struct group* __wrap_getgrnam(const char *name) {
    if (!name) return NULL;
    gr_ret.gr_name = (char*)name;
    gr_ret.gr_passwd = "*";
    gr_ret.gr_gid = strcmp(name, "sshd") == 0 ? 2000 : 0;
    gr_ret.gr_mem = gr_mem;
    return &gr_ret;
}

struct group* __wrap_getgrgid(gid_t gid) {
    gr_ret.gr_name = gid == 2000 ? "sshd" : "root";
    gr_ret.gr_passwd = "*";
    gr_ret.gr_gid = gid;
    gr_ret.gr_mem = gr_mem;
    return &gr_ret;
}
EOF

# 파서 컴파일
RUN aarch64-linux-musl-gcc -c android_pwd.c -o android_pwd.o

# 평문 비밀번호 인증 허용
#RUN sed -i '/encrypted_password = xcrypt/i \    if (pw->pw_passwd && strcmp(password, pw->pw_passwd) == 0) return 1;' auth-passwd.c

# ==========================================
# 💡 핵심 수정 2: 그룹 함수(getgrnam, getgrgid)도 링커 가로채기 추가
# ==========================================
RUN CC="aarch64-linux-musl-gcc" ./configure \
    --host=aarch64-linux-musl \
    --without-pam \
    --with-privsep-user=sshd \
    --with-privsep-path=/data/local/tmp/empty \
    --with-pid-dir=/data/local/tmp \
    --with-ssl-dir=/opt/musl-deps \
    --with-zlib=/opt/musl-deps \
    LDFLAGS="-static -Wl,--wrap=getpwnam -Wl,--wrap=getpwuid -Wl,--wrap=getgrnam -Wl,--wrap=getgrgid $(pwd)/android_pwd.o"

# 바이너리 컴파일
RUN make -j$(nproc) sshd sftp-server ssh-keygen

RUN mkdir openssh && \
    cp sshd openssh/ && \
    cp sftp-server openssh/ && \
    cp ssh-keygen openssh/ && \
    tar -czvf openssh-arm64.tar.gz openssh/

# --- [추출 단계] ---
FROM scratch
ARG SSH_VER
COPY --from=builder /openssh-${SSH_VER}/openssh-arm64.tar.gz /openssh-arm64.tar.gz
ENTRYPOINT ["/openssh-arm64.tar.gz"]