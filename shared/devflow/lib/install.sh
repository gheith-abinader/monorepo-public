. "$DEVFLOW_LIB_DIR/config.install.sh"
. "$DEVFLOW_LIB_DIR/manual.install.sh"

install_project() {
  local project="$1"
  local PROJECTS_DIR="$PROJECTS_DIR/$project"
  local script

  [ -d "$PROJECTS_DIR" ] || fail "project not found: $project"

  set -- "$PROJECTS_DIR"/*.sh
  [ -f "$1" ] || fail "no installer scripts found in project: $project"

  for script in "$PROJECTS_DIR"/*.sh; do
    [ -f "$script" ] || continue
    printf '==> Running %s for project %s\n' "$(basename "$script")" "$project"
    bash "$script"
  done

  config_install "$project"

  install_manual_steps "$project"
}
