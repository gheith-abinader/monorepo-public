manual_add() {
  local project="$1"
  local stepname="$2"
  local PROJECTS_DIR="$PROJECTS_DIR/$project"
  local file
  local step_id

  [ -d "$PROJECTS_DIR" ] || fail "project not found: $project"

  file="$(printf '%s/%s/%s\n' "$PROJECTS_DIR" "$project" "$MANUAL_STEPS_FILENAME")"
  step_id="$(printf '%s:%s\n' "$project" "$stepname")"

  if  grep -qxF "id: $step_id" "$file" 2>/dev/null; then
    printf 'Manual step already exists: %s\n' "$step_id"
    return 0
  fi

  touch "$file"

  if [ -s "$file" ]; then
    printf '\n' >> "$file"
  fi

  {
    printf 'id: %s\n' "$step_id"
    printf 'body: \n'
  } >> "$file"

  printf 'Added manual step: %s\n' "$step_id"
  printf 'Edit this file to fill the body: %s\n' "$file"
}
