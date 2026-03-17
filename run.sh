#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Starting SuperCollider IDE..."
echo "==> Evaluate the main block in boot.scd with Ctrl+Enter to boot."
pw-jack scide "$SCRIPT_DIR/boot.scd" &

echo "==> Opening VS Code..."
code "$SCRIPT_DIR"
