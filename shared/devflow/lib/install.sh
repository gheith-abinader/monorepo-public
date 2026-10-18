. "$DEVFLOW_LIB_DIR/config.install.sh"
. "$DEVFLOW_LIB_DIR/manual.install.sh"

install_project() {
  local project="$1"
  local project_dir="$PROJECTS_DIR/$project"
  local script

  [ -d "$project_dir" ] || fail "project not found: $project"

  set -- "$project_dir"/*.sh
  [ -f "$1" ] || fail "no installer scripts found in project: $project"

  for script in "$project_dir"/*.sh; do
    [ -f "$script" ] || continue
    printf '==> Running %s for project %s\n' "$(basename "$script")" "$project"
    bash "$script"
  done

  config_install "$project"

  install_manual_steps "$project"
}
