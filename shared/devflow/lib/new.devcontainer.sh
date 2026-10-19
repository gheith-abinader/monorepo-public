new_devcontainer() {
  local project_name="${1:-}"
  local project_dir
  local template_dir
  local template_target

  [ -n "$project_name" ] || fail "usage: devflow new devcontainer <project-name>"

  case "$project_name" in
    .*|*/*|*..*|*[!a-zA-Z0-9_-]*)
      fail "invalid project name '$project_name'; use letters, numbers, '_' or '-' and do not start with a dot"
      ;;
  esac

  project_dir="$MONOREPO_ROOT/$project_name"
  template_dir="$MONOREPO_ROOT/shared/templates/.devcontainer"
  template_target="$project_dir/.devcontainer"

  [ -d "$template_dir" ] ||
    fail "Dev Container template not found: $template_dir"
  [ -f "$template_dir/devcontainer.json" ] ||
    fail "Dev Container template is missing devcontainer.json: $template_dir"
  if [ -e "$project_dir" ] || [ -L "$project_dir" ]; then
    fail "project already exists: $project_dir"
  fi

  mkdir -p "$template_target"
  if ! cp -R "$template_dir/." "$template_target/"; then
    rm -rf -- "$project_dir"
    fail "failed to copy Dev Container template"
  fi

  if ! ln -s "../shared/devflow" "$project_dir/devflow"; then
    rm -rf -- "$project_dir"
    fail "failed to create DevFlow symlink"
  fi

  printf 'Created project: %s\n' "$project_dir"
  printf 'Template:        %s\n' "$template_target"
  printf 'DevFlow link:    %s -> ../shared/devflow\n' "$project_dir/devflow"
}
