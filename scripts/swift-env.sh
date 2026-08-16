#!/usr/bin/env bash
# Source this file to use the locally installed Swift toolchain:
#   source scripts/swift-env.sh
export SWIFT_BIN="${SWIFT_BIN:-$HOME/swiftbin/usr/lib/swift/bin}"
export PATH="$SWIFT_BIN:$PATH"
export LD_LIBRARY_PATH="$HOME/swiftbin/usr/lib:${LD_LIBRARY_PATH:-}"
