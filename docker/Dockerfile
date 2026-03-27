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

CMD ["php-fpm"]
