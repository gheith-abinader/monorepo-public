config_integrity_resolve() {
  local definition="$1"
  local raw_config_file="$2"
  local expanded_config_file
  if ! expanded_config_file=$(expand_config_path "$raw_config_file"); then
      return 1
  fi

  local tmp_definition

  [ -f "$definition" ] || return 0
  [ -f "$expanded_config_file" ] || return 0

  tmp_definition="$(mktemp)"
  config_contents "$definition" > "$tmp_definition"

  if diff -q "$tmp_definition" "$expanded_config_file" >/dev/null; then
      echo "No differences found."
  else
      vimdiff "$tmp_definition" "$expanded_config_file"

      #overwrite contents with $temp_definition
      local marker_line
      local tmp_out
      marker_line="$(grep -n '^contents:[[:space:]]*$' "$definition" | head -n 1 | sed 's/:.*//')"
      [ -n "$marker_line" ] || fail "missing contents header in dotfile definition: $definition"
      tmp_out="$(mktemp)"
      {
          sed -n "1,${marker_line}p" "$definition"
          cat "$tmp_definition"
      } > "$tmp_out"

      mv -f "$tmp_out" "$definition"
  fi

  rm -f "$tmp_definition"
}

config_contents() {
  local definition="$1"
  local marker_line
  marker_line="$(grep -n '^contents:[[:space:]]*$' "$definition" | head -n 1 | sed 's/:.*//')"
  [ -n "$marker_line" ] || fail "missing contents header in dotfile definition: $definition"
  sed "1,${marker_line}d" "$definition"
}

expand_config_path() {
  local path=$1
  local variable_name
  local suffix
  local variable_value

  case "$path" in
    '${'[A-Za-z_][A-Za-z0-9_]*'}'*)
      # Example: ${HOME}/.zshrc
      variable_name="${path#\$\{}"
      variable_name="${variable_name%%\}*}"
      suffix="${path#\$\{$variable_name\}}"
      ;;
    '$'[A-Za-z_][A-Za-z0-9_]*)
      # Example: $HOME/.zshrc
      variable_name="${path#\$}"
      variable_name="${variable_name%%/*}"
      suffix="${path#\$$variable_name}"
      ;;
    *)
      # Nothing to expand.
      printf '%s\n' "$path"
      return 0
      ;;
  esac

  if [[ -z "${!variable_name+x}" ]]; then
    printf 'Undefined variable in config path: %s\n' "$variable_name" >&2
    return 1
  fi

  variable_value="${!variable_name}"
  printf '%s%s\n' "$variable_value" "$suffix"
}
