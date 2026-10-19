cmd_manual_done() {
  local current

  current="$(head -n 1 "$DEVFLOW_CURRENT_FILE")"

  [ -n "$current" ] || fail "no current manual step; run 'devflow manual next' first"

  local tmp_file
  tmp_file="$(mktemp)"
  grep -vxF "$current" "$DEVFLOW_PENDING_FILE" > "$tmp_file" || true
  mv "$tmp_file" "$DEVFLOW_PENDING_FILE"
  : > "$DEVFLOW_CURRENT_FILE"

  if [ -s "$DEVFLOW_PENDING_FILE" ]; then
    printf 'Manual step completed: %s\n' "$current"
    printf 'Run: devflow manual next\n'
  else
    printf 'Manual step completed: %s\n' "$current"
    printf 'No pending manual steps remain.\n'
  fi
}
