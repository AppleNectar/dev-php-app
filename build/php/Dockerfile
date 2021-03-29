ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm-alpine3.12

ARG CONTAINERS_TIMEZONE
ARG WEB_USER_NAME
ARG WEB_USER_GROUP
ARG WEB_USER_UID
ARG WEB_USER_GID
ARG PHP_NODE_ENABLE
ARG NODE_VERSION

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
        linux-headers \
        openssl \
        icu-dev \
        libbz2 \
        libxml2-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        readline-dev \
        libedit-dev \
        libzip-dev

# Create user and group
RUN set -eux \
    && groupadd -g ${WEB_USER_GID} ${WEB_USER_GROUP} \
    && useradd -u ${WEB_USER_UID} -g ${WEB_USER_GROUP} -s /sbin/nologin -m ${WEB_USER_NAME} \
    && mkdir /home/${WEB_USER_NAME}/public_html \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_NAME} /home/${WEB_USER_NAME}/public_html \
    && chmod -R 775 /home/${WEB_USER_NAME}/public_html

# Create configs
RUN set -eux \
    && cp -i /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && sed -i -e "s|;date.timezone =|date.timezone = ${CONTAINERS_TIMEZONE}|g" /usr/local/etc/php/php.ini \
    && sed -i -e "/^user = /s/user/;user/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -e "/^group = /s/group/;group/g" /usr/local/etc/php-fpm.d/www.conf \
    && cp -i /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "/^user = /s/user/;user/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "/^group = /s/group/;group/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "/^listen = /s/127.0.0.1:9000/9000/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "s/;listen.group = www-data/listen.group = ${WEB_USER_GROUP}/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "s/;listen.mode/listen.mode/g" /usr/local/etc/php-fpm.d/zzz-www.conf

# Install php libraries
RUN set -eux \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && touch /var/log/xdebug.log \
    && chmod 664 /var/log/xdebug.log \
    && chown root:${WEB_USER_GROUP} /var/log/xdebug.log \
    && pecl install redis

# Install php extensions
RUN set -eux \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install bcmath intl pdo_mysql simplexml xml readline zip

# Install composer
RUN set -eux \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install php-cs-fixer
RUN set -eux \
    && wget https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v2.17.3/php-cs-fixer.phar -O php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer

# Install nodejs
RUN set -eux \
    && if ${PHP_NODE_ENABLE}; then \
        wget -q4 https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz; \
        tar zxf node-v${NODE_VERSION}.tar.gz; \
        cd node-v${NODE_VERSION} && ./configure --prefix=/usr/local/nodejs/${NODE_VERSION} && make -j$(nproc) && make install; \
        ln -s /usr/local/nodejs/${NODE_VERSION}/bin /usr/local/nodejs/bin; \
        echo 'export PATH=/usr/local/nodejs/bin:$PATH' > /home/${WEB_USER_NAME}/.profile; \
        cd /usr/local/src && rm -rf node-v${NODE_VERSION} && rm -f node-v${NODE_VERSION}.tar.gz; \
    fi

COPY conf/xdebug.ini /usr/local/etc/php/conf.d/
COPY conf/phpredis.ini /usr/local/etc/php/conf.d/

USER ${WEB_USER_NAME}

WORKDIR /home/${WEB_USER_NAME}/public_html
