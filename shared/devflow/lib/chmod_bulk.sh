chmod_bulk() {
    local folder file target
    local -a files

    if [ $# -lt 2 ]; then
        echo "usage: chmod_bulk <folder> <file1> [file2 ...]" >&2
        return 2
    fi

    folder=$1
    shift
    files=("$@")

    if [ -z "$folder" ]; then
        echo "chmod_bulk: folder must not be empty" >&2
        return 2
    fi

    mkdir -p "$folder" || {
        echo "chmod_bulk: failed to create folder: $folder" >&2
        return 1
    }

    for file in "${files[@]}"; do
        if [ -z "$file" ]; then
            echo "chmod_bulk: skipped empty file name" >&2
            continue
        fi

        target="$folder/$file"

        touch "$target" || {
            echo "chmod_bulk: failed to create file: $target" >&2
            return 1
        }

        chmod +x "$target" || {
            echo "chmod_bulk: failed to chmod: $target" >&2
            return 1
        }

        printf 'chmod +x -> %s\n' "$target"
    done
}
