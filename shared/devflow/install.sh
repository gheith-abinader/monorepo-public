#!/usr/bin/env bash
set -euo pipefail

DEVFLOW_INSTALL_DIR="/opt/devflow"
DEVFLOW_BIN="/usr/local/bin/devflow"
log() { printf '[devflow-feature] %s\n' "$*"; }
fail() { printf '[devflow-feature] Error: %s\n' "$*" >&2; exit 1; }

DEVFLOW_INSTALLER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GH_REPO_ROOT="$(cd -- "$DEVFLOW_INSTALLER_DIR/../.." && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-}"
PROJECTS_DIR="${PROJECTS_DIR:-${PROJECT_ROOT:-$GH_REPO_ROOT}}"
DEVFLOW_SOURCE_LIB_DIR="$DEVFLOW_INSTALLER_DIR/lib"
DEVFLOW_TEMPLATE="$DEVFLOW_INSTALLER_DIR/devflow.sh"
DEVFLOW_TEMP="$(mktemp)"
trap 'rm -f "$DEVFLOW_TEMP" "${DEVFLOW_TEMP}.final"' EXIT

for cmd in bash install mkdir chmod sed cp; do
  command -v "$cmd" >/dev/null 2>&1 || fail "required command not found: $cmd"
done
[[ -f "$DEVFLOW_TEMPLATE" ]] || fail "missing Feature payload: devflow.sh"
[[ -d "$DEVFLOW_SOURCE_LIB_DIR" ]] || fail "missing Feature payload: lib/"

log "Project directory: $PROJECTS_DIR"
log "Installing DevFlow application files..."
mkdir -p "$DEVFLOW_INSTALL_DIR/lib" /usr/local/bin

if [[ -n "$PROJECT_ROOT" ]]; then
  sed '/# BEGIN HOST-ONLY COMMAND/,/# END HOST-ONLY COMMAND/d' "$DEVFLOW_TEMPLATE" > "$DEVFLOW_TEMP"
else
  cp "$DEVFLOW_TEMPLATE" "$DEVFLOW_TEMP"
fi
sed "s|__PROJECTS_DIR__|$PROJECTS_DIR|g" "$DEVFLOW_TEMP" > "${DEVFLOW_TEMP}.final"
install -m 0755 "${DEVFLOW_TEMP}.final" "$DEVFLOW_INSTALL_DIR/devflow.sh"

for file in "$DEVFLOW_SOURCE_LIB_DIR"/*.sh; do
  [[ -f "$file" ]] || continue
  filename="$(basename "$file")"
  if [[ -n "$PROJECT_ROOT" ]]; then
    [[ "$filename" == "new.devcontainer.sh" ]] && continue
    if [[ "$filename" == "help.sh" ]]; then
      sed '/# BEGIN HOST-ONLY COMMAND/,/# END HOST-ONLY COMMAND/d' "$file" > "${DEVFLOW_TEMP}.final"
      install -m 0644 "${DEVFLOW_TEMP}.final" "$DEVFLOW_INSTALL_DIR/lib/$filename"
      continue
    fi
  fi
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
