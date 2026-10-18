#!/usr/bin/env bash
set -euo pipefail

DEVFLOW_INSTALL_DIR="/opt/devflow"
DEVFLOW_BIN="/usr/local/bin/devflow"
PROJECTS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
DEVFLOW_SOURCE_LIB_DIR="$PROJECTS_DIR/shared/devflow/lib"
DEVFLOW_TEMPLATE="$PROJECTS_DIR/shared/devflow/devflow.sh"
DEVFLOW_TEMP="$(mktemp)"

log() {
    printf '[devflow-feature] %s\n' "$*"
}

fail() {
    printf '[devflow-feature] Error: %s\n' "$*" >&2
    exit 1
}

for cmd in bash install mkdir chmod; do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "required command not found: $cmd"
done

[[ -f "$DEVFLOW_TEMPLATE" ]] ||
    fail "missing Feature payload: devflow.sh"

[[ -d "$DEVFLOW_SOURCE_LIB_DIR" ]] ||
    fail "missing Feature payload: lib/"

log "Installing devflow application files..."

mkdir -p "$DEVFLOW_INSTALL_DIR/lib" /usr/local/bin

log "Installing global devflow wrapper..."

sed "s|__PROJECTS_DIR__|$PROJECTS_DIR|g" \
    "$DEVFLOW_TEMPLATE" >"$DEVFLOW_TEMP"

chmod +x "$DEVFLOW_TEMP"
install -m 0755 "$DEVFLOW_TEMP" \
    "$DEVFLOW_INSTALL_DIR/devflow.sh"



for file in "$DEVFLOW_SOURCE_LIB_DIR"/*.sh; do
    [[ -f "$file" ]] || continue
    install -m 0644 "$file" "$DEVFLOW_INSTALL_DIR/lib/"
done

cat > "$DEVFLOW_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

exec /usr/bin/env bash /opt/devflow/devflow.sh "$@"
EOF

chmod 0755 "$DEVFLOW_BIN"

log "devflow installed at $DEVFLOW_BIN"
log "Run: devflow --help"