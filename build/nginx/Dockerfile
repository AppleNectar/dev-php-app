FROM nginx:1.18.0-alpine

ARG WEB_USER_NAME
ARG WEB_USER_GROUP
ARG WEB_USER_UID
ARG WEB_USER_GID

# Package install and update
RUN set -eux \
    && apk update \
    && apk --no-cache add \
        tzdata \
        procps \
        net-tools \
        shadow \
        vim \
        sudo \
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
    && wget -O /usr/local/bin/mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 \
    && chmod +x /usr/local/bin/mkcert

# Create user and group
RUN set -eux \
    && groupadd -g ${WEB_USER_GID} ${WEB_USER_GROUP} \
    && useradd -u ${WEB_USER_UID} -g ${WEB_USER_GROUP} -s /sbin/nologin -m ${WEB_USER_NAME} \
    && mkdir /home/${WEB_USER_NAME}/public_html \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_NAME} /home/${WEB_USER_NAME}/public_html \
    && chmod -R 775 /home/${WEB_USER_NAME}/public_html

# Make self-certificate files and DH key parameter file for localhost
RUN set -eux \
    && mkcert -install \
    && mkdir /etc/nginx/certs \
    && mkcert -cert-file /etc/nginx/certs/server.crt -key-file /etc/nginx/certs/server.key localhost 127.0.0.1 \
    && openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048

COPY conf/default.conf /etc/nginx/conf.d/

# Configure nginx
# - Change process execute user
# - Change log format(add self hostname)
# - Server token disable
# - gzip enable
# - Allow long server name
# - Change keppalive timeout
# - Change localhost document root
RUN set -eux \
    && sed -i -e "/^user /s/nginx/${WEB_USER_NAME}/g" /etc/nginx/nginx.conf \
    && sed -i -e 's/"$http_user_agent"/"$http_user_agent" "$host"/g' /etc/nginx/nginx.conf \
    && sed -i -e "/^http {/a \    server_tokens off;" /etc/nginx/nginx.conf \
    && sed -i -e "/#gzip/s/#//g" /etc/nginx/nginx.conf \
    && sed -i -e "/gzip.*on/a \    server_names_hash_bucket_size 128;" /etc/nginx/nginx.conf \
    && sed -i -e "/server_names_hash_bucket_size/a \    fastcgi_buffers 16 32k;" /etc/nginx/nginx.conf \
    && sed -i -e "/fastcgi_buffers/a \    fastcgi_buffer_size 64k;" /etc/nginx/nginx.conf \
    && sed -i -e "/fastcgi_buffer_size/a \    fastcgi_busy_buffers_size 64k;" /etc/nginx/nginx.conf \
    && sed -i -e "/keepalive_timeout/s/65/5/g" /etc/nginx/nginx.conf \
    && DOCUMENT_ROOT="/home/${WEB_USER_NAME}/public_html" \
    && sed -i -e "1,/root/ s/\/usr\/share\/nginx\/html/${DOCUMENT_ROOT//\//\\/}/g" /etc/nginx/conf.d/default.conf \
    && unset DOCUMENT_ROOT

WORKDIR /home/${WEB_USER_NAME}/public_html
