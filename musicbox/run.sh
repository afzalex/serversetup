#!/usr/bin/env bash
set -euo pipefail

# Resolve the MusicBox directory even when launched from elsewhere.
MUSICBOX_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# yt-dlp needs Deno to resolve YouTube's JavaScript challenges.
export PATH="$HOME/.deno/bin:$PATH"

# Run the project's Mopidy installation with its configuration.
exec "$MUSICBOX_DIR/.venv/bin/mopidy" \
  --config "$MUSICBOX_DIR/config/mopidy.conf" "$@"

