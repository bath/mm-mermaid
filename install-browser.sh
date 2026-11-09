#!/bin/bash
# Download the chrome-headless-shell that the installed mmdc pins.
# install.sh runs this, and mm runs it when mmdc cannot find its browser.
set -euo pipefail

# mmdc needs the exact chrome-headless-shell its bundled puppeteer pins,
# and the Homebrew formula does not ship it.
mods="$(brew --prefix mermaid-cli)/libexec/lib/node_modules/@mermaid-js/mermaid-cli/node_modules"
version="$(sed -n "s/.*'chrome-headless-shell': '\([^']*\)'.*/\1/p" "$mods/puppeteer-core/lib/puppeteer/revisions.js")"
"$(brew --prefix node)/bin/node" "$mods/@puppeteer/browsers/lib/main-cli.js" \
  install "chrome-headless-shell@$version" --path "${PUPPETEER_CACHE_DIR:-$HOME/.cache/puppeteer}"
