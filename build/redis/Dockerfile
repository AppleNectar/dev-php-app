FROM redis:6-alpine

RUN set -eux \
  && apk update \
  && apk --no-cache add tzdata

CMD ["sh", "-c", "exec redis-server --requirepass \"${REDIS_AUTH_PASS}\""]
