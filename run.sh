#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Starting SuperCollider + SuperDirt..."
pw-jack sclang "$SCRIPT_DIR/boot.scd" &
SCLANG_PID=$!
echo "sclang PID: $SCLANG_PID"

echo "==> Opening VS Code..."
code "$SCRIPT_DIR"

# If VS Code exits, kill sclang too
wait $SCLANG_PID
