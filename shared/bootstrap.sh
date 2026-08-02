#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[bootstrap] %s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

need_cmd sudo
need_cmd bash
need_cmd mkdir
need_cmd chmod
need_cmd install
need_cmd mktemp
need_cmd sed

sudo mkdir -p /usr/local/bin
sudo chmod 755 /usr/local/bin

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")." && pwd)"
TVA_TEMPLATE="$REPO_ROOT/shared/tvaBootstrap/tva.sh"

TVA_BIN="/usr/local/bin/tva"
TVA_LIB="/usr/local/bin/tvaLib"
TMP_TVA="$(mktemp)"

log "Using repo root: $REPO_ROOT"
log "Installing global tva wrapper..."

sed "s|__REPO_ROOT__|$REPO_ROOT|g" \
    "$TVA_TEMPLATE" > "$TMP_TVA"

chmod +x "$TMP_TVA"
sudo install -m 0755 "$TMP_TVA" "$TVA_BIN"
rm -f "$TMP_TVA"

sudo mkdir -p "$TVA_LIB"

for file in "$REPO_ROOT"/lib/*; do
    [ -f "$file" ] || continue
    sudo install -m 0644 "$file" "$TVA_LIB/"
done

mkdir -p "${HOME}/.tva"
touch "${HOME}/.tva/pending_manual_steps"
touch "${HOME}/.tva/current_manual_step"

log "tva installed globally at $TVA_BIN"
log "Bootstrap complete."
log "You can now run: tva list"
log "If you move this repository, rerun ./bootstrap.sh so the global wrapper points to the new path."
