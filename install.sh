#!/bin/bash
# Install mm: mermaid-cli, the headless Chrome it renders with, and a link
# to mm on your PATH. Safe to run again, e.g. after `brew upgrade mermaid-cli`.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
bin_dir="${MM_BIN_DIR:-$HOME/.local/bin}"

command -v brew >/dev/null || { echo "install.sh: Homebrew is required" >&2; exit 1; }
brew list mermaid-cli >/dev/null 2>&1 || brew install mermaid-cli

# mmdc needs the exact chrome-headless-shell its bundled puppeteer pins,
# and the Homebrew formula does not ship it.
mods="$(brew --prefix mermaid-cli)/libexec/lib/node_modules/@mermaid-js/mermaid-cli/node_modules"
version="$(sed -n "s/.*'chrome-headless-shell': '\([^']*\)'.*/\1/p" "$mods/puppeteer-core/lib/puppeteer/revisions.js")"
"$(brew --prefix node)/bin/node" "$mods/@puppeteer/browsers/lib/main-cli.js" \
  install "chrome-headless-shell@$version" --path "$HOME/.cache/puppeteer"

mkdir -p "$bin_dir"
ln -sf "$repo/mm" "$bin_dir/mm"
echo "Installed $bin_dir/mm"
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "Add $bin_dir to your PATH" ;;
esac
