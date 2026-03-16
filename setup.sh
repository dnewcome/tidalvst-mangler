#!/usr/bin/env bash
set -e

echo "==> Installing SuperCollider..."
sudo apt update
sudo apt install -y supercollider supercollider-ide supercollider-server supercollider-language jackd2 qjackctl

echo "==> Installing ghcup dependencies..."
sudo apt install -y curl build-essential libgmp-dev libffi-dev libncurses-dev

echo "==> Installing ghcup (GHC + Cabal)..."
export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export BOOTSTRAP_HASKELL_INSTALL_NO_STACK=1
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Source ghcup env so we can use cabal immediately
# shellcheck disable=SC1091
source "$HOME/.ghcup/env"

echo "==> Installing TidalCycles..."
cabal update
if grep -q "package-id tidal" "$HOME/.ghc/x86_64-linux-9.6.7/environments/default" 2>/dev/null; then
    echo "tidal already installed, skipping."
else
    cabal install tidal --lib
fi

echo "==> Installing VSTPlugin SC extension..."
VSTPLUGIN_VERSION="0.6.2"
VSTPLUGIN_ARCHIVE="VSTPlugin-linux-x86_64-${VSTPLUGIN_VERSION}.zip"
VSTPLUGIN_URL="https://github.com/Spacechild1/vstplugin/releases/download/v${VSTPLUGIN_VERSION}/${VSTPLUGIN_ARCHIVE}"
SC_EXT_DIR="$HOME/.local/share/SuperCollider/Extensions"

mkdir -p "$SC_EXT_DIR"
curl -L "$VSTPLUGIN_URL" -o "/tmp/${VSTPLUGIN_ARCHIVE}"
unzip -o "/tmp/${VSTPLUGIN_ARCHIVE}" -d "$SC_EXT_DIR"
rm "/tmp/${VSTPLUGIN_ARCHIVE}"
echo "VSTPlugin installed to $SC_EXT_DIR"

echo ""
echo "Done. Next steps:"
echo ""
echo "1. Open SuperCollider IDE: scide"
echo "   - Open boot.scd, update the VST plugin path, then Ctrl+Shift+Enter to evaluate"
echo "   - Run VSTPlugin.search(s) in SC to list available plugins on your system"
echo ""
echo "2. Start TidalCycles in your editor (VS Code + Tidal extension, or vim-tidal)"
echo "   - Open start.tidal and evaluate patterns with the keybinding"
