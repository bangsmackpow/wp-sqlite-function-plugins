FROM php:8.2-fpm

ENV WP_ADMIN_USER=admin \
    WP_ADMIN_PASSWORD=changeme \
    WP_ADMIN_EMAIL=admin@example.com \
    WP_URL=http://localhost

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    unzip \
    ca-certificates \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    zlib1g-dev \
    libxml2-dev \
    libonig-dev \
    pkg-config \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j$(nproc) pdo pdo_sqlite mbstring xml gd zip json

WORKDIR /var/www/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
CMD ["sh", "/usr/local/bin/entrypoint.sh"]
