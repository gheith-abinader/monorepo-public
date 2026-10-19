#!/usr/bin/env bash
set -euo pipefail

DEVFLOW_INSTALL_DIR="/opt/devflow"
DEVFLOW_BIN="/usr/local/bin/devflow"

log() {
    printf '[devflow-feature] %s\n' "$*"
}

fail() {
    printf '[devflow-feature] Error: %s\n' "$*" >&2
    exit 1
}

# Locate the DevFlow source in the monorepo.
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

# Default project directory preserves the current behavior.
PROJECT_DIR="$REPO_ROOT"
log "Default project directory: $PROJECT_DIR"

# DevFlow source files always come from the repository.
DEVFLOW_SOURCE_LIB_DIR="$REPO_ROOT/shared/devflow/lib"
DEVFLOW_TEMPLATE="$REPO_ROOT/shared/devflow/devflow.sh"

DEVFLOW_TEMP="$(mktemp)"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir)
            if [[ $# -lt 2 || -z "$2" ]]; then
                fail "Error: --project-dir requires a path."
                exit 2
            fi

            PROJECT_DIR="$2"
            shift 2
            ;;

        --help|-h)
            log "Usage: $0 [--project-dir PATH]"
            exit 0
            ;;

        *)
            fail "Error: unknown argument: $1"
            log "Usage: $0 [--project-dir PATH]" >&2
            exit 2
            ;;
    esac
done

log "user-specified project directory: $PROJECT_DIR"

# Normalize the path without requiring it to exist yet.
# A Dev Container workspace mount might not exist during image build.
if [[ "$PROJECT_DIR" = /* ]]; then
    :
else
    PROJECT_DIR="$PWD/$PROJECT_DIR"
fi

log "Project directory: $PROJECT_DIR"

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

sed "s|__PROJECTS_DIR__|$PROJECT_DIR|g" \
    "$DEVFLOW_TEMPLATE" >"$DEVFLOW_TEMP"

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