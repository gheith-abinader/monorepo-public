list_projects() {
  local format="text"
  local dir
  local base
  local i
  local -a projects=()

  if [ "${1:-}" = "--format" ]; then
    [ $# -ge 2 ] || fail "missing value for --format"
    format="$2"
    shift 2
  elif [ $# -gt 0 ]; then
    fail "unknown argument for list: $1"
  fi

  for dir in "$REPO_ROOT"/*/; do
    [ -d "$dir" ] || continue
    base="$(basename "$dir")"

    case "$base" in
      lib) continue ;;
    esac

    set -- "$dir"/*.sh
    [ -f "$1" ] || continue
    projects[${#projects[@]}]="$base"
  done

  case "$format" in
    text)
      printf '%s\n' "${projects[@]}"
      ;;
    json)
      printf '['
      i=0
      while [ "$i" -lt "${#projects[@]}" ]; do
        [ "$i" -gt 0 ] && printf ','
        printf '"%s"' "${projects[$i]}"
        i=$((i + 1))
      done
      printf ']\n'
      ;;
    *)
      fail "unsupported format: $format"
      ;;
  esac
}
