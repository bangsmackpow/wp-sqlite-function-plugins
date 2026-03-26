#!/bin/sh
set -e

WP_DIR="/var/www/html"
WP_URLENV="${WP_URL:-http://localhost}"
ADMIN_USER="${WP_ADMIN_USER:-admin}"
ADMIN_PASS="${WP_ADMIN_PASSWORD:-changeme}"
ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"

ROOT_UID=0
ROOT_GID=0

# Install WP-CLI if not present
if ! command -v wp >/dev/null 2>&1; then
  echo "[entrypoint] Installing WP-CLI"
  curl -sS https://get.wp-cli.org/ | bash -s -- -v 2>/dev/null
  mv wp-cli.phar /usr/local/bin/wp
  chmod +x /usr/local/bin/wp
fi

# Allow for host-mounted content to be used as WP root
if [ -d "/opt/docker/wp-CUSTOMER" ]; then
  WP_DIR="/opt/docker/wp-CUSTOMER"
fi

echo "[entrypoint] WP root: $WP_DIR"

if [ ! -d "$WP_DIR" ]; then
  mkdir -p "$WP_DIR"
fi

cd "$WP_DIR"

# Download WordPress if not present
if [ ! -f "$WP_DIR/wp-config.php" ]; then
  echo "[entrypoint] Downloading WordPress core"
  wp core download --path="$WP_DIR" --allow-root
fi

# Create wp-config.php tailored for SQLite usage (via plugin) if missing
if [ ! -f "$WP_DIR/wp-config.php" ]; then
cat > "$WP_DIR/wp-config.php" <<'PHP'
<?php
// Basic WordPress configuration with SQLite support
define('DB_NAME', 'wordpress');
define('DB_USER', '');
define('DB_PASSWORD', '');
define('DB_HOST', 'sqlite:/var/www/html/wp-sqlite.db');
define('WP_DEBUG', false);
define('WP_AUTO_UPDATE_CORE', true);
define('WP_MEMORY_LIMIT', '256M');
// Cloudflare Real IP support: prefer CF telling IP when behind Cloudflare
if (isset($_SERVER['HTTP_CF_CONNECTING_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_CF_CONNECTING_IP'];
}
if ( !defined('ABSPATH') )
  define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
PHP
fi

# Install WordPress if not installed
if ! wp core is-installed --path="$WP_DIR" >/dev/null 2>&1; then
  echo "[entrypoint] Running core install (SQLite mode)"
  wp core install \
    --path="$WP_DIR" \
    --url "$WP_URLENV" \
    --title "WP SQLite" \
    --admin_user "$ADMIN_USER" \
    --admin_password "$ADMIN_PASS" \
    --admin_email "$ADMIN_EMAIL" \
    --skip-email --allow-root
fi

# Install and activate the requested plugins (auto-update enabled in mu-plugin)
PLUGINS=(offload-media-lite cloudflare forminator rank-math google-site-kit smtp2go super-page-cache)
for slug in "${PLUGINS[@]}"; do
  if ! wp plugin is-installed "$slug" --path="$WP_DIR" >/dev/null 2>&1; then
    echo "[entrypoint] Installing plugin: $slug"
    wp plugin install "$slug" --activate --path="$WP_DIR" --allow-root || true
  else
    echo "[entrypoint] Plugin already installed: $slug"
  fi
done

# Ensure mu-plugin for auto-updates exists
MU_DIR="$WP_DIR/wp-content/mu-plugins"
mkdir -p "$MU_DIR"
cat > "$MU_DIR/auto-update.php" <<'PHP'
<?php
add_filter('auto_update_core','__return_true');
add_filter('auto_update_plugin','__return_true');
add_filter('auto_update_theme','__return_true');
PHP

# Setup Cloudflare REAL IP in nginx config via environment hints (UI-driven activation later)
echo "[entrypoint] Starting services"

# Start PHP-FPM and Nginx
php-fpm -R &
NGINX_PID=$!
nginx -g "daemon off;" &
NGINX_PID2=$!

wait $NGINX_PID $NGINX_PID2
