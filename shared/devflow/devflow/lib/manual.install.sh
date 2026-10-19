install_manual_steps() {
    local project="$1"
    local manual_steps_file="$PROJECTS_DIR/$project/$MANUAL_STEPS_FILENAME"

    [ -f "$manual_steps_file" ] || return 0

    local step_id
    local has_manual_steps=0

    while IFS= read -r step_id; do
        has_manual_steps=1
        if ! grep -qxF "$step_id" "$DEVFLOW_PENDING_FILE" 2>/dev/null; then
            printf '%s\n' "$step_id" >> "$DEVFLOW_PENDING_FILE"
        fi
    done < <(
        grep '^id: ' "$manual_steps_file" | cut -c5-
    )

    [ "$has_manual_steps" -eq 1 ] || return 0

    local bell
    bell="$(printf '\a')"

    printf '%s%s' "$bell" "$bell"
    printf '\n'
    printf '============================================================\n'
    printf 'MANUAL STEPS REQUIRED FOR PROJECT: %s\n' "$project"
    printf 'Run: devflow manual next\n'
    printf '============================================================\n'
    printf '\n'
}
