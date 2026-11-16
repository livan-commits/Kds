#!/usr/bin/env bash
# Experimental Kds firmware backend for Ubuntu/WSL2.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_SOURCE="$SCRIPT_DIR/../patches/kodeos-radio-disabled.patch"
ROOT="${KDS_FIRMWARE_ROOT:-$HOME/.local/share/kds-firmware}"
IDF_DIR="$ROOT/esp-idf"
SIM_DIR="$ROOT/kode-sim"
OS_DIR="$ROOT/KodeOS"
IDF_VERSION="v6.1"
KODE_SIM_COMMIT="e9404e4e0a9834044fb1ada36976a090c25cb70d"
KODEOS_COMMIT="9bcfdb71b763ee7b5c14106358643ea611fc97db"

usage() { echo "Usage: $0 setup | run"; }
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
  "$IDF_DIR/install.sh" esp32p4
  if [ ! -d "$SIM_DIR/.git" ]; then git clone https://github.com/kodediy/kode-sim.git "$SIM_DIR"; fi
  git -C "$SIM_DIR" fetch --depth 1 origin "$KODE_SIM_COMMIT"
  git -C "$SIM_DIR" checkout --detach "$KODE_SIM_COMMIT"
  if [ ! -d "$OS_DIR/.git" ]; then git clone https://github.com/kodediy/KodeOS.git "$OS_DIR"; fi
  git -C "$OS_DIR" fetch --depth 1 origin "$KODEOS_COMMIT"
  git -C "$OS_DIR" checkout --detach "$KODEOS_COMMIT"
  git -C "$OS_DIR" submodule update --init --recursive
  test -s "$PATCH_SOURCE" || { echo "Missing Kds patch: $PATCH_SOURCE" >&2; exit 2; }
  cp "$PATCH_SOURCE" "$ROOT/kodeos-radio-disabled.patch"
  echo "Pinned sources prepared in $ROOT."
  echo "Start the simulator with: $0 run"
}
run_sim() {
  for path in "$IDF_DIR/export.sh" "$SIM_DIR/Cargo.toml" "$OS_DIR/CMakeLists.txt" "$ROOT/kodeos-radio-disabled.patch"; do
    test -e "$path" || { echo "Missing $path; run '$0 setup' first." >&2; exit 2; }
  done
  if ! git -C "$OS_DIR" apply --reverse --check "$ROOT/kodeos-radio-disabled.patch" >/dev/null 2>&1; then
    git -C "$OS_DIR" apply --check "$ROOT/kodeos-radio-disabled.patch"
    git -C "$OS_DIR" apply "$ROOT/kodeos-radio-disabled.patch"
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
