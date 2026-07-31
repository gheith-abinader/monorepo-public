. "$SCRIPT_DIR/tvaLib/config.common.sh"
. "$SCRIPT_DIR/tvaLib/chmod_bulk.sh"
export -f chmod_bulk

config_install(){
    local project="$1"
    local config_folder="$REPO_ROOT/$project/$DOTFILES_DIRNAME"

    [[ -d "$config_folder" ]] || return 0

    shopt -s dotglob nullglob
    for config in "$config_folder"/*; do
        [[ -f "$config" ]] || continue # skip folder if not file

        target=$(config_location "$config")
        target_dir="$(dirname "$target")"
        mkdir -p "$target_dir"
        config_contents "$config" > "$target"
        printf 'Installed dotfile directly: %s\n' "$target"
    done
    shopt -u dotglob nullglob

    return 0
}

config_location() {
  local definition="$1"
  local path
  local expanded_path

  path="$(sed -n '1s/^location:[[:space:]]*//p' "$definition")"
  path="$(printf '%s' "$path" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

  [ -n "$path" ] || fail "missing location header in dotfile definition: $definition"

  expanded_path=$(expand_config_path "$path")

  printf '%s\n' "$expanded_path"
}
