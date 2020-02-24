
FROM openresty/openresty:1.15.8.2-7-alpine-fat

COPY src/ /usr/local/lib/lua
RUN chmod +x /usr/local/lib/lua/*.lua \
  && mkdir -p /etc/nginx/conf.d \
  && mkdir -p /var/log/nginx \
  && mkdir -p /var/cache/nginx \
  && rm -f /etc/nginx/conf.d/default.conf \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && chown -R nobody:nobody /usr/local/openresty \
  && touch /var/run/nginx.pid \
  && chown -R nobody:nobody /var/run/nginx.pid \
  && chown -R nobody:nobody /var/cache/nginx
COPY --chown=nobody:nobody conf/proxy.conf /etc/nginx/conf.d/
COPY --chown=nobody:nobody conf/nginx.conf /usr/local/openresty/nginx/conf/
COPY --chown=nobody:nobody docker/docker-entrypoint.sh /usr/local/bin

ENTRYPOINT [ "docker-entrypoint.sh" ]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl -H "User-Agent: Dokcer-healthcheck" -f http://localhost:8080/status/healthz || exit 1
EXPOSE 8080
USER nobody

CMD ["nginx", "-g", "daemon off;"]
