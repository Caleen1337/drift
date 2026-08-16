#!/usr/bin/env bash
# Install the Swift toolchain on Arch Linux WITHOUT root (user-local).
# Uses the Arch-native `swift-bin` package (built against Arch's libraries),
# plus `libxml2-legacy` which the toolchain requires.
#
# Alternatively (recommended, one command with sudo):
#   yay -S swift-bin
set -euo pipefail

PREFIX="${PREFIX:-$HOME/swiftbin}"
SWIFT_URL="https://geo-mirror.chaotic.cx/chaotic-aur/x86_64/swift-bin-6.3.3-1-x86_64.pkg.tar.zst"
XML_URL="https://us.mirrors.cicku.me/archlinux/extra/os/x86_64/libxml2-legacy-2.13.9-2-x86_64.pkg.tar.zst"
XML_URL_ALT="https://geo-mirror.chaotic.cx/chaotic-aur/x86_64/libxml2-legacy-2.13.9-2-x86_64.pkg.tar.zst"

mkdir -p "$PREFIX"
cd /tmp

echo "Downloading swift-bin..."
curl -L "$SWIFT_URL" -o swift-bin.pkg.tar.zst

echo "Downloading libxml2-legacy..."
curl -L "$XML_URL" -o libxml2-legacy.pkg.tar.zst || \
  curl -L "$XML_URL_ALT" -o libxml2-legacy.pkg.tar.zst

echo "Extracting to $PREFIX ..."
tar --zstd -xf swift-bin.pkg.tar.zst -C "$PREFIX"
tar --zstd -xf libxml2-legacy.pkg.tar.zst -C "$PREFIX"
rm -f swift-bin.pkg.tar.zst libxml2-legacy.pkg.tar.zst

echo
echo "Done. Use it with:"
echo "  source scripts/swift-env.sh"
echo "  swift --version"
