WordPress + SQLite in a single container (Alpine, Nginx + PHP 8.5) with pre-installed plugins

Overview
- Base image: wordpress:beta-php8.5-fpm-alpine
- SQLite backend via sqlite-database plugin (from WordPress repository)
- Plugins pre-installed and activated:
  - Offload Media Lite
  - Cloudflare
  - Forminator
  - Rank Math
  - Site Kit by Google
  - SMTP2Go
  - Super Page Cache

CI/CD
- GitHub Actions workflow builds and pushes to GHCR at:
  ghcr.io/bangsmackpow/wp-sqlite-function-plugins
- Tags:
  - latest
  - sha
  - release tag (when a release is published)

- Usage
- Build locally (requires Docker buildx):
  docker build -t wp-sqlite-function-plugins:dev .
- Run container with Docker Compose (recommended for this plan):
  docker-compose up -d
- Access the site at http://localhost:8080
- Admin at http://localhost:8080/wp-admin with credentials from env vars
- Data persists in ./data/wp-content on the host
- Run container:
  docker run -p 8080:80 -e SITE_URL=http://localhost:8080 -e SITE_TITLE="My SQLite WP" -e WP_ADMIN_USER=admin -e WP_ADMIN_PASSWORD=admin123 -e WP_ADMIN_EMAIL=admin@example.com ghcr.io/bangsmackpow/wp-sqlite-function-plugins:latest

Notes and caveats
- SQLite backend is provided via a WordPress plugin (sqlite-database). Some plugins/themes may assume MySQL features; test accordingly.
- The bootstrap script installs and activates the plugins on first run and bootstraps WordPress core install using environment variables.
- This is a single-container approach as requested. For production, consider additional hardening, backups, and monitoring.

Credits
- Base image: wordpress:beta-php8.5-fpm-alpine
- SQLite plugin: sqlite-database (WordPress repository)
