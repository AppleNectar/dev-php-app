FROM alpine:3.12
LABEL maintainer="AppleNectar"

# Package install and update
RUN set -eux \
    && apk update \
    && apk --no-cache add \
        tini \
        tzdata \
        openrc \
        procps \
        net-tools \
        shadow \
        wget \
        less \
        tree \
        unzip \
        zip \
        bzip2 \
        git \
        gcc \
        g++ \
        make \
        autoconf \
        m4 \
        curl \
        openssl \
        libbz2 \
        mariadb \
        mariadb-client

# Setup openrc
RUN set -eux \
    && sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf \
    && echo 'rc_provide="loopback net"' >> /etc/rc.conf \
    && sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf \
    && sed -i '/tty/d' /etc/inittab \
    && sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
    && sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh \
    && sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
    && rc-status \
    && touch /run/openrc/softlevel

# Setup mariadb config
RUN sed -i 's/^skip-networking/skip-networking = 0\nskip-bind-address\nskip-name-resolve\nport = 3306\ncharacter-set-server = utf8mb4/g' /etc/my.cnf.d/mariadb-server.cnf

COPY ./scripts/entrypoint.sh /usr/local/src/

RUN chmod +x /usr/local/src/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/local/src/entrypoint.sh"]
