#!/bin/bash

# Build PK3 into ./dist and optionally copy to a target directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_NAME="predators-hellspawn-hunters-redux.pk3"
DIST_DIR="$SCRIPT_DIR/dist"
ACC_BIN="${ACC_BIN:-/home/jono/tools/acc/acc}"
ACC_INC="${ACC_INC:-/home/jono/tools/acc}"

if [ ! -x "$ACC_BIN" ]; then
  echo "ACC not found at $ACC_BIN (set ACC_BIN if needed)." >&2
  exit 1
fi

mkdir -p "$DIST_DIR"

echo "Compiling ACS objects..."
"$ACC_BIN" -i "$ACC_INC" "$SCRIPT_DIR/src/PREDSPE.acs" "$SCRIPT_DIR/src/ACS/PREDSPE.o"
"$ACC_BIN" -i "$ACC_INC" "$SCRIPT_DIR/src/foot.acs" "$SCRIPT_DIR/src/ACS/foot.o"

OUT_PATH="$DIST_DIR/$OUTPUT_NAME"
if [ -f "$OUT_PATH" ]; then
  echo "Removing old $OUT_PATH..."
  rm "$OUT_PATH"
fi

echo "Building $OUT_PATH..."
(
  cd "$SCRIPT_DIR/src"
  zip -r "$OUT_PATH" . -x "*.git*" -x "*jdredalerts*" -x "*.DS_Store"
)

echo "Build complete! Created $OUT_PATH"

if [ -n "$1" ]; then
  DEST_DIR="$1"
  if [ ! -d "$DEST_DIR" ]; then
    echo "Destination is not a directory: $DEST_DIR" >&2
    exit 1
  fi
  cp -f "$OUT_PATH" "$DEST_DIR/$OUTPUT_NAME"
  echo "Copied to $DEST_DIR/$OUTPUT_NAME"
fi
