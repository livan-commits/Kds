#!/usr/bin/env bash
# Kds firmware backend for Ubuntu/WSL2.
# Installs the pinned official KodeOS, kode-sim and ESP-IDF toolchain.
set -euo pipefail

ROOT="${KDS_FIRMWARE_ROOT:-$HOME/.local/share/kds-firmware}"
IDF_DIR="$ROOT/esp-idf"
SIM_DIR="$ROOT/kode-sim"
OS_DIR="$ROOT/KodeOS"
IDF_VERSION="v6.1"
KODE_SIM_COMMIT="e9404e4e0a9834044fb1ada36976a090c25cb70d"
KODEOS_COMMIT="9bcfdb71b763ee7b5c14106358643ea611fc97db"

usage() {
  echo "Usage: $0 setup | run"
}

install_system_deps() {
  sudo apt-get update
  sudo apt-get install -y git curl wget flex bison gperf python3 python3-pip python3-venv \
    cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 pkg-config \
    build-essential mtools rsync
}

setup() {
  mkdir -p "$ROOT"
  install_system_deps
  if [ ! -d "$IDF_DIR/.git" ]; then
    git clone --branch "$IDF_VERSION" --depth 1 --recursive https://github.com/espressif/esp-idf.git "$IDF_DIR"
  fi
  if [ ! -f "$IDF_DIR/install.sh" ]; then
    echo "ESP-IDF checkout is incomplete: $IDF_DIR" >&2; exit 1
  fi
  "$IDF_DIR/install.sh" esp32p4
  if [ ! -d "$SIM_DIR/.git" ]; then
    git clone https://github.com/kodediy/kode-sim.git "$SIM_DIR"
  fi
  git -C "$SIM_DIR" fetch --depth 1 origin "$KODE_SIM_COMMIT"
  git -C "$SIM_DIR" checkout --detach "$KODE_SIM_COMMIT"
  if [ ! -d "$OS_DIR/.git" ]; then
    git clone --recurse-submodules https://github.com/kodediy/KodeOS.git "$OS_DIR"
  fi
  git -C "$OS_DIR" fetch --depth 1 origin "$KODEOS_COMMIT"
  git -C "$OS_DIR" checkout --detach "$KODEOS_COMMIT"
  git -C "$OS_DIR" submodule update --init --recursive
  git -C "$OS_DIR" apply --check "$SIM_DIR/../Kds/patches/kodeos-radio-disabled.patch" 2>/dev/null || true
  echo
  echo "Sources prepared in $ROOT."
  echo "Next: run this script with 'run'. The first build downloads ESP-IDF and esp-emu components."
}

run_sim() {
  if [ ! -d "$IDF_DIR" ] || [ ! -d "$SIM_DIR" ] || [ ! -d "$OS_DIR" ]; then
    echo "Run '$0 setup' first." >&2; exit 2
  fi
  # Re-apply the tracked Kds compatibility patch only if it is not already present.
  if ! grep -q 'CONFIG_KODEOS_RADIO' "$OS_DIR/components/kgui"/*.c 2>/dev/null; then
    echo "Check the KodeOS no-radio patch before continuing; source tree may need preparation." >&2
  fi
  # Kds ships the patch alongside this script; copy it into the WSL data root.
  PATCH="$ROOT/kodeos-radio-disabled.patch"
  if [ -f "$PATCH" ]; then
    git -C "$OS_DIR" apply --reverse --check "$PATCH" 2>/dev/null || git -C "$OS_DIR" apply "$PATCH"
  else
    echo "Missing patch: $PATCH" >&2; exit 2
  fi
  source "$IDF_DIR/export.sh"
  if [ ! -x "$SIM_DIR/target/release/kode-sim" ]; then
    cargo build --release --manifest-path "$SIM_DIR/Cargo.toml" -p kode-sim
  fi
  export KODE_SIM_CACHE="$ROOT/cache"
  export KODE_SIM_TOOLS="$ROOT/tools"
  exec "$SIM_DIR/target/release/kode-sim" run "$OS_DIR"
}

case "${1:-}" in
  setup) setup ;;
  run) run_sim ;;
  *) usage; exit 2 ;;
esac
