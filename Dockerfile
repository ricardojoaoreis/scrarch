ARG ALPINE_VERSION=3.13.0
FROM alpine:$ALPINE_VERSION AS bootstrap
ARG ARCHLINUX_BOOTSTRAP_VERSION=2021.01.01
ARG BOOTSTRAP_ARCH_DIR=/tmp/arch
ARG CHARMAP=UTF-8
ARG LANGUAGE=en_US
ARG LOCALE=$LANGUAGE.$CHARMAP
ARG REPO_DATE=2021/01/30
RUN wget -P /tmp https://archive.archlinux.org/iso/$ARCHLINUX_BOOTSTRAP_VERSION/archlinux-bootstrap-$ARCHLINUX_BOOTSTRAP_VERSION-x86_64.tar.gz && \
    mkdir -p "$BOOTSTRAP_ARCH_DIR" && \
    tar xzf /tmp/archlinux-bootstrap-$ARCHLINUX_BOOTSTRAP_VERSION-x86_64.tar.gz -C $BOOTSTRAP_ARCH_DIR --strip-components 1 && \
    sed -i 's/CheckSpace/#CheckSpace/' $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo '[options]' >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf  && \
    echo 'NoExtract = usr/share/help/*' >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo 'NoExtract = usr/share/gtk-doc/* usr/share/doc/*' >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo 'NoExtract = usr/share/locale/* usr/share/X11/locale/* usr/share/i18n/*' >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo "NoExtract = !*locale*/$LANGUAGE*/* !usr/share/i18n/charmaps/$CHARMAP.gz !usr/share/*locale*/locale.*" >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo "NoExtract = !usr/share/*locales/$LANGUAGE !usr/share/*locales/i18n* !usr/share/*locales/iso*" >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo 'NoExtract = usr/share/*locales/trans*' >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo 'NoExtract = usr/share/man/* usr/share/info/*' >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo 'NoExtract = usr/share/vim/vim*/lang/*' >> $BOOTSTRAP_ARCH_DIR/etc/pacman.conf && \
    echo "Server = https://archive.archlinux.org/repos/$REPO_DATE/\$repo/os/\$arch" > $BOOTSTRAP_ARCH_DIR/etc/pacman.d/mirrorlist && \
    echo "$LOCALE $CHARMAP" > $BOOTSTRAP_ARCH_DIR/etc/locale.gen && \
    echo "LANG=\"$LOCALE\"" > $BOOTSTRAP_ARCH_DIR/etc/locale.conf

FROM scratch
ARG BOOTSTRAP_ARCH_DIR=/tmp/arch
ARG CHARMAP=UTF-8
ARG LOCALTIME=UTC
COPY --from=bootstrap $BOOTSTRAP_ARCH_DIR /
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Rnsc --noconfirm systemd && \
    pacman -R --noconfirm arch-install-scripts && \
    pacman -Syu --noconfirm sed gzip && \
    find /usr/share/locale/ -mindepth 1 -maxdepth 1 -type d -exec rm -r {} + 2> /dev/null && \
    find /usr/share/i18n/charmaps -type f -not -name $CHARMAP.gz -delete 2> /dev/null && \
    find /etc -regextype posix-extended -regex ".+\.pac(new|save)" -delete 2> /dev/null && \
    ln -s /usr/share/zoneinfo/$LOCALTIME /etc/localtime && \
    locale-gen && \
    rm -rf /usr/share/man /usr/share/i18n /usr/share/doc /README \
    yes | pacman -Scc
