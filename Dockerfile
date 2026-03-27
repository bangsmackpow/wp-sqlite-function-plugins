FROM wordpress:beta-php8.5-fpm-alpine

LABEL maintainer="OpenCode - AI assistant" \
      description="WordPress with SQLite support (via sqlite-database plugin) on Alpine PHP8.5-FPM"

# Lightweight tools for setup
RUN apk add --no-cache curl bash ca-certificates

# Install WP-CLI
RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp

# Expose WordPress port
EXPOSE 80

# Bootstrap script to install plugins and configure SQLite on first run
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=5s --start-period=30s --retries=3 \
  CMD ["bash","-lc","if /usr/local/bin/wp core is-installed --path=/var/www/html --allow-root; then http_code=$(curl -s -o /dev/null -w \"%{http_code}\" http://localhost/); if [ \"$http_code\" = \"200\" ] || [ \"$http_code\" = \"301\" ]; then exit 0; else exit 1; fi; else exit 1; fi"]

CMD ["php-fpm"]
