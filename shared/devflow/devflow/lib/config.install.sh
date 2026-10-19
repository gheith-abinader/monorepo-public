. "$DEVFLOW_LIB_DIR/config.common.sh"
. "$DEVFLOW_LIB_DIR/chmod_bulk.sh"
export -f chmod_bulk

config_install(){
    local project="$1"
    local config_folder="$PROJECTS_DIR/$project/$DOTFILES_DIRNAME"

    [[ -d "$config_folder" ]] || return 0

    shopt -s dotglob nullglob
    for config in "$config_folder"/*; do
        [[ -f "$config" ]] || continue # skip folder if not file

        target=$(config_location "$config")
        target_dir="$(dirname "$target")"
        mkdir -p "$target_dir"
        config_integrity_resolve $config $target
        config_contents "$config" > "$target"
        printf 'Installed dotfile directly: %s\n' "$target"
    done
    shopt -u dotglob nullglob

    return 0
}
