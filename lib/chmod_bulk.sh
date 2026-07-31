chmod_bulk() {
    local __entry folder files file target
    local -a __entries file_arr

    if [ $# -eq 1 ] && [[ "$1" != *:* ]]; then
        eval "__entries=(\"\${$1[@]}\")"
    else
        __entries=("$@")
    fi

    for __entry in "${__entries[@]}"; do
        folder="${__entry%%:*}"
        files="${__entry#*:}"

        mkdir -p "$folder"

        IFS=',' read -ra file_arr <<< "$files"

        for file in "${file_arr[@]}"; do
            target="$folder/$file"
            touch "$target"
            if [ -f "$target" ]; then
                chmod +x -- "$target"
                echo "chmod +x -> $target"
            else
                echo "Missing file, skipped: $target" >&2
            fi
        done
    done
}
