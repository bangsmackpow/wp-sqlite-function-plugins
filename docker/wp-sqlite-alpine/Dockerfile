FROM php:8.2-fpm-alpine

ENV NGINX_PORT=80 \
    WP_ADMIN_USER=admin \
    WP_ADMIN_PASSWORD=changeme \
    WP_ADMIN_EMAIL=admin@example.com \
    WP_URL=http://localhost

RUN apk update && apk add --no-cache \
    nginx \
    curl \
    bash \
    shadow \
    tzdata \
    ca-certificates \
    unzip \
    icu \
    sqlite \
    sqlite-dev \
    oniguruma \
    oniguruma-dev \
    libxml2 \
    libxml2-dev \
    libzip \
    libzip-dev \
    pkgconfig \
    libpng \
    libpng-dev \
    zlib \
    zlib-dev \
    freetype \
    freetype-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libwebp \
  libwebp-dev \
  && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
  && docker-php-ext-install pdo pdo_sqlite xml gd zip json \
  && apk del .build-deps

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
