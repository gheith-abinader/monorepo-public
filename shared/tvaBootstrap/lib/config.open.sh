# dotfile config time
# A dotfile definition is stored at <project>/dotfiles/<name>.
# Format:
#   location: ~/.zshrc
#   contents:
#   ...actual config content...
#

. "$SCRIPT_DIR/tvaLib/config.common.sh"

config_open(){
    local project="$1"
    local config_path="$2"

    case "$config_file" in
      "~"* )
        fail "config_file_path cannot use ~; use an absolute path instead (for example /Users/name/file)"
        ;;
    esac

    if [ -d "$config_path" ]; then
        fail "$config_path is a directory, not a file" >&2
        return 1
    fi

    local project_root="$REPO_ROOT/$project"
    if [ ! -d "$project_root" ]; then
        fail "$project not found as a directory"
    fi

    local config_file_name=$(basename "$config_path")
    local config_definition="$project_root/$DOTFILES_DIRNAME/$config_file_name"
    if ! mkdir -p "$(dirname "$config_definition")"; then
        fail "could not create directory for $config_definition"
        return 1
    fi

    if ! touch "$config_definition"; then
        fail "could not create $config_definition"
        return 1
    fi

    if [ ! -s "$config_definition" ]; then
        {
            printf 'location: %s\n' "$config_path"
            printf 'contents:\n'
        } > "$config_definition"
    fi

    config_integrity_resolve "$config_definition" "$config_path"

    open "$config_definition"
}
