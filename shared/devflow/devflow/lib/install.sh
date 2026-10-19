. "$DEVFLOW_LIB_DIR/config.install.sh"
. "$DEVFLOW_LIB_DIR/manual.install.sh"

install_project() {
  local project="$1"
  local PROJECT_DIR="$PROJECTS_DIR/$project"
  local script

  [ -d "$PROJECT_DIR" ] || fail "project not found: $project"

  set -- "$PROJECT_DIR"/*.sh
  [ -f "$1" ] || fail "no installer scripts found in project: $project"

  for script in "$PROJECT_DIR"/*.sh; do
    [ -f "$script" ] || continue
    printf '==> Running %s for project %s\n' "$(basename "$script")" "$project"
    bash "$script"
  done

  config_install "$project"

  install_manual_steps "$project"
}
