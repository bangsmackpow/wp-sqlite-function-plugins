#!/usr/bin/env bash
set -euo pipefail

WP_CLI=/usr/local/bin/wp
WP_PATH=/var/www/html
DB_FILE="${WP_PATH}/wp-content/wp-sqlite.db"

SITE_URL="${SITE_URL:-http://localhost}"
SITE_TITLE="${SITE_TITLE:-WordPress SQLite Demo}"
WP_ADMIN_USER="${WP_ADMIN_USER:-admin}"
WP_ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-admin12345}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"

# Ensure wordpress config dir exists
mkdir -p "$WP_PATH"

# Create a sqlite database file if it does not exist
if [ ! -f "$DB_FILE" ]; then
  touch "$DB_FILE"
  chown -R www-data:www-data "$WP_PATH" "$DB_FILE" 2>/dev/null || true
fi

bootstrap() {
  echo "Bootstrapping WordPress SQLite setup..."

  # Install WordPress core if not present in this directory
  if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "wp-config.php missing in $WP_PATH; skipping core install bootstrap here."
  fi

  # Install and activate required plugins (SQLite plugin is from WordPress repo - sqlite-database)
  PLUGINS=(offload-media-lite cloudflare forminator rank-math site-kit smtp2go super-page-cache sqlite-database)

  for slug in "${PLUGINS[@]}"; do
    if "$WP_CLI" plugin is-installed "$slug" --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
      echo "Plugin $slug already installed"
    else
      echo "Installing plugin: $slug"
      if ! "$WP_CLI" plugin install "$slug" --activate --path="$WP_PATH" --allow-root; then
        echo "Warning: Failed to install plugin $slug. Continuing..."
      fi
    fi
  done

  # Configure SQLite DB via wp-config.php constants if not already defined
  if ! grep -q "DB_TYPE" "$WP_PATH/wp-config.php" 2>/dev/null; then
    echo "Configuring SQLite in wp-config.php"
    cat >> "$WP_PATH/wp-config.php" <<'PHP'
define('DB_TYPE', 'sqlite');
define('DB_FILE', __DIR__ . '/wp-sqlite.db');
PHP
    # Ensure file exists after config write
    touch "$DB_FILE"
  fi

  # Install WordPress core if not installed yet (using sqlite backend via plugin)
  if ! "$WP_CLI" core is-installed --path="$WP_PATH" --allow-root; then
    echo "Installing WordPress core (SQLite backend will be used if plugin loads)"
    "$WP_CLI" core install \
      --path="$WP_PATH" \
      --url="$SITE_URL" \
      --title="$SITE_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL" \
      --skip-email \
      --allow-root
  fi

  # Ensure ownership for the webserver user
  chown -R www-data:www-data "$WP_PATH" 2>/dev/null || true
}

if [ -z "${DISABLE_WP_BOOTSTRAP:-}" ]; then
  bootstrap
fi

echo "Starting PHP-FPM..."
exec /usr/local/bin/docker-entrypoint.sh php-fpm "$@"
