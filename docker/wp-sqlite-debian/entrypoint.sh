#!/bin/sh
set -e

WP_DIR="/var/www/html"
WP_URLENV="${WP_URL:-http://localhost}"
ADMIN_USER="${WP_ADMIN_USER:-admin}"
ADMIN_PASS="${WP_ADMIN_PASSWORD:-changeme}"
ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"

# Install WP-CLI if not present
if ! command -v wp >/dev/null 2>&1; then
  curl -sS https://get.wp-cli.org/ | bash -s -- -v 2>/dev/null
  mv wp-cli.phar /usr/local/bin/wp
  chmod +x /usr/local/bin/wp
fi

cd "$WP_DIR" 2>/dev/null || mkdir -p "$WP_DIR" && cd "$WP_DIR"

if [ ! -f "$WP_DIR/wp-config.php" ]; then
  wp core download --path="$WP_DIR" --allow-root
fi
if [ ! -f "$WP_DIR/wp-config.php" ]; then
  cat > "$WP_DIR/wp-config.php" <<'PHP'
<?php
define('DB_HOST', 'localhost');
define('DB_NAME', 'wordpress');
define('DB_USER', '');
define('DB_PASSWORD', '');
define('WP_DEBUG', false);
define('WP_AUTO_UPDATE_CORE', true);
define('WP_MEMORY_LIMIT', '256M');
require_once(__DIR__ . '/wp-settings.php');
PHP
fi

if ! wp core is-installed --path="$WP_DIR" >/dev/null 2>&1; then
  wp core install \
    --path="$WP_DIR" \
    --url "$WP_URLENV" \
    --title "WP SQLite" \
    --admin_user "$ADMIN_USER" \
    --admin_password "$ADMIN_PASS" \
    --admin_email "$ADMIN_EMAIL" \
    --skip-email --allow-root
fi

# Install plugins (auto-update via Mu-Plugin can be added if needed)
PLUGINS=(offload-media-lite cloudflare forminator rank-math google-site-kit smtp2go super-page-cache)
for slug in "${PLUGINS[@]}"; do
  if ! wp plugin is-installed "$slug" --path="$WP_DIR" >/dev/null 2>&1; then
    wp plugin install "$slug" --activate --path="$WP_DIR" --allow-root || true
  fi
done

echo "[entrypoint] Starting services"
nginx -g 'daemon off;' &
PHP_FPM_PID=$!
wait $PHP_FPM_PID
