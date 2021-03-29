FROM alpine:3.12
RUN set -eux \
    && apk update \
    && apk --no-cache add \
        tzdata \
        mariadb \
        mariadb-client
COPY ./scripts/entrypoint.sh /usr/local/src/
RUN chmod +x /usr/local/src/entrypoint.sh
EXPOSE 3306
ENTRYPOINT ["/usr/local/src/entrypoint.sh"]
