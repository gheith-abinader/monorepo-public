. "$SCRIPT_DIR/tvaLib/config.common.sh"

config_apply(){
    local project="$1"
    local config_folder="$REPO_ROOT/$project/$DOTFILES_DIRNAME"
    local config="$2"
    local config_path="$config_folder/$config"

    if [ -z "$project" ]; then
        echo "config_refresh: missing project name" >&2
        return 2
    fi

    if [ -z "$config" ]; then
        echo "config_refresh: missing config file definition" >&2
        return 2
    fi

    if [ ! -d "$config_folder" ]; then
        echo "config_refresh: project not found: '$project' (missing folder: $config_folder)" >&2
        return 3
    fi

    if [ ! -e "$config_path" ]; then
        echo "config_refresh: config file not found in project '$project': '$config'" >&2
        return 4
    fi

    shopt -s dotglob nullglob
    target=$(config_location "$config_path")
    target_dir="$(dirname "$target")"
    mkdir -p "$target_dir"
    config_integrity_resolve $config $target
    config_contents "$config_path" > "$target"
    printf 'Installed dotfile directly: %s\n' "$target"
    shopt -u dotglob nullglob

    return 0
}
