#!/bin/bash
# Rebuild the README demo: ../assets/demo.gif and ../assets/demo.mp4.
# Needs mmdc (see ../install.sh) and ffmpeg.
set -euo pipefail
cd "$(dirname "$0")"

[[ -d node_modules ]] || npm install --silent
npx playwright install chromium >/dev/null

mmdc -q -i retry-flow.mmd -o preview.png -s 6 -b white

frames="$(mktemp -d -t mm-demo)"
trap 'rm -rf "$frames"' EXIT
node record.mjs "$frames" 30

mkdir -p ../assets
ffmpeg -loglevel error -y -framerate 30 -i "$frames/%05d.png" \
  -vf "scale=1600:-2:flags=lanczos" -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -movflags +faststart \
  ../assets/demo.mp4
ffmpeg -loglevel error -y -framerate 30 -i "$frames/%05d.png" \
  -vf "fps=15,scale=960:-2:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
  ../assets/demo.gif
ls -lh ../assets/demo.*
