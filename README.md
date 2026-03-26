WordPress with SQLite (Alpine, Nginx + PHP 8.2) Docker image

Overview
- Alpine-based image with Nginx and PHP-FPM 8.2
- Pure WordPress with SQLite support (no 3rd party DBs)
- Preinstalled plugins (auto-update) as requested:
  - Offload Media Lite
  - Cloudflare
  - Forminator
  - Rank Math
  - Site Kit by Google
  - SMTP2Go
  - Super Page Cache
- WordPress core is available out-of-the-box and is configured to use SQLite
- WP core and plugin auto-updates enabled
- Cloudflare Real IP support in Nginx config
- WP config is adaptable via the UI on first boot (UI-driven setup)

Repository layout (high level)
- docker/wp-sqlite-alpine/
  - Dockerfile
  - entrypoint.sh
  - nginx.conf
  - php.ini
  - .github/ (workflow for GHCR builds)
  - .dockerignore
- .github/workflows/build-and-push.yml
- README.md

Usage (local development)
- Mount host WordPress directory to container at /opt/docker/wp-CUSTOMER:/var/www/html
- Example: docker run -p 8080:80 -v /path/to/wp:/opt/docker/wp-CUSTOMER:rw ghcr.io/bangsmackpow/wp-sqlite-function-plugins:latest
- Access at http://localhost:8080

Local build and push helper
- There is a helper script at `scripts/build_and_push.sh` to build and push the image to GHCR.
- Prereqs: Docker with Buildx configured, GHCR login. Usage: `./scripts/build_and_push.sh latest` (or other tags, comma-separated).

CI/CD
- Push to main or create release to trigger GHCR build and publish the image
- Images are pushed to ghcr.io/bangsmackpow/wp-sqlite-function-plugins with tags: latest, <sha>, php8.2-alpine

Notes
- The startup flow creates WordPress core (if not present) and configures SQLite via the included plugin
- The UI will guide the initial WordPress setup; a basic wp-config.php is prepared for SQLite and Cloudflare Real IP
- If you need to adjust the plugin list or versions, update the PLUGINS array in the entrypoint script

Next steps
- Confirm plugin slugs (see PLUGINS array in entrypoint.sh) and adjust as needed
- Optionally add a docker-compose.yml for local testing and volume management
