FROM alpine:3.19

ENV NGINX_PORT=80 \
    PHP_VER=8.2 \
    WP_ADMIN_USER=admin \
    WP_ADMIN_PASSWORD=changeme \
    WP_ADMIN_EMAIL=admin@example.com \
    WP_URL=http://localhost

RUN apk add --no-cache \
    nginx \
    curl \
    bash \
    shadow \
    tzdata \
    ca-certificates \
    unzip \
    icu \
    php8 \
    php8-fpm \
    php8-opcache \
    php8-mbstring \
    php8-xml \
    php8-gd \
    php8-zip \
    php8-pdo_sqlite \
    php8-sqlite3 \
    php8-pdo \
    php8-json \
    php8-apcu \
    bash-procs

# Nginx configuration and runtime directories
RUN mkdir -p /var/www/html /var/cache/nginx /run/nginx && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/www/html/wp-content/mu-plugins

COPY nginx.conf /etc/nginx/nginx.conf
COPY php.ini /usr/local/etc/php/php.ini

RUN mkdir -p /usr/local/bin && \
    adduser -D -h /var/www/html -s /bin/sh www-data && \
    chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
CMD ["sh", "/usr/local/bin/entrypoint.sh"]
