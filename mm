#!/bin/bash
# mm — render the Mermaid diagram on the clipboard and open it in Preview.
# Accepts raw Mermaid, a ```mermaid fenced block, or a copy from the Claude
# terminal (where the fence is gone and a bare "mermaid" line is left).
# Output: ~/Desktop/mermaid-<timestamp>.{svg,png}
set -euo pipefail

repo="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

out_dir="$HOME/Desktop"
scale="${MM_SCALE:-4}"

clip="$(pbpaste)"
if [[ -z "${clip//[[:space:]]/}" ]]; then
  echo "mm: the clipboard is empty" >&2
  exit 1
fi

base="$out_dir/mermaid-$(date +%Y%m%d-%H%M%S)"
tmp="$(mktemp -d -t mm)"
trap 'rm -rf "$tmp"' EXIT
src="$tmp/diagram.mmd"

# Drop ``` fence lines and a leading bare "mermaid" language label,
# then remove the indent the terminal adds to every line.
printf '%s\n' "$clip" | awk '
  /^[[:space:]]*```/ { next }
  !started && /^[[:space:]]*$/ { next }
  !started && /^[[:space:]]*mermaid[[:space:]]*$/ { started = 1; next }
  { started = 1; print }
' | awk '
  { lines[NR] = $0
    if ($0 ~ /[^[:space:]]/) {
      match($0, /^[[:space:]]*/)
      if (min == "" || RLENGTH < min) min = RLENGTH
    } }
  END { for (i = 1; i <= NR; i++) print substr(lines[i], min + 1) }
' > "$src"

render() {
  mmdc -q -i "$src" -o "$base.svg" &&
    mmdc -q -i "$src" -o "$base.png" -s "$scale" -b white
}

# A new mmdc can pin a Chrome that is not downloaded yet. Get it, then retry.
if ! err="$(render 2>&1 >/dev/null)"; then
  if [[ $err != *"Could not find chrome-headless-shell"* ]]; then
    printf '%s\n' "$err" >&2
    exit 1
  fi
  echo "mm: downloading the headless Chrome that mmdc needs" >&2
  "$repo/install-browser.sh" >&2
  render
fi

open -a Preview "$base.png"
echo "$base.png"
