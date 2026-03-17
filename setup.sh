#!/usr/bin/env bash
set -e

echo "==> Installing SuperCollider..."
sudo apt update
sudo apt install -y supercollider supercollider-ide supercollider-server supercollider-language sc3-plugins jackd2 qjackctl

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

echo "==> Installing Surge XT..."
SURGE_DEB_URL="https://github.com/surge-synthesizer/releases-xt/releases/download/1.3.4/surge-xt-linux-x64-1.3.4.deb"
curl -L "$SURGE_DEB_URL" -o /tmp/surge-xt.deb
sudo dpkg -i /tmp/surge-xt.deb
rm /tmp/surge-xt.deb

echo "==> Installing VSTPlugin build dependencies..."
sudo apt install -y cmake git libx11-dev supercollider-dev

SC_EXT_DIR="$HOME/.local/share/SuperCollider/Extensions"
SC_INCLUDE_DIR="/usr/include/SuperCollider"

# Find SC headers — location varies by distro
if [ ! -d "$SC_INCLUDE_DIR" ]; then
    SC_INCLUDE_DIR="$(dpkg -L supercollider-dev 2>/dev/null | grep -m1 'include/SuperCollider$' || echo '')"
fi
if [ -z "$SC_INCLUDE_DIR" ] || [ ! -d "$SC_INCLUDE_DIR" ]; then
    SC_INCLUDE_DIR="$(find /usr -name 'SCPlugin.h' 2>/dev/null | head -1 | xargs dirname | xargs dirname || echo '')"
fi
echo "Using SC headers at: $SC_INCLUDE_DIR"

echo "==> Building VSTPlugin from source..."
VSTPLUGIN_VERSION="0.6.2"
BUILD_DIR="/tmp/vstplugin-build"

mkdir -p "$SC_EXT_DIR"
rm -rf "$BUILD_DIR"
git clone --depth 1 --branch "v${VSTPLUGIN_VERSION}" \
    https://github.com/Spacechild1/vstplugin.git "$BUILD_DIR"

echo "==> Fetching VST3 SDK..."
git clone --depth 1 --recurse-submodules \
    https://github.com/steinbergmedia/vst3sdk.git \
    "$BUILD_DIR/vst/VST_SDK/VST3_SDK"

mkdir -p "$BUILD_DIR/build"
cmake -S "$BUILD_DIR" -B "$BUILD_DIR/build" \
    -DCMAKE_BUILD_TYPE=Release \
    -DSC_INCLUDEDIR="$SC_INCLUDE_DIR" \
    -DSC_INSTALLDIR="$SC_EXT_DIR" \
    -DPD=OFF \
    -DVST2=OFF \
    -DSUPERNOVA=OFF
cmake --build "$BUILD_DIR/build" -j"$(nproc)"
cmake --build "$BUILD_DIR/build" -t install

rm -rf "$BUILD_DIR"
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
