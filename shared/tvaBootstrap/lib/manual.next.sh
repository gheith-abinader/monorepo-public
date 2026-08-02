cmd_manual_next() {
 # FINDING THE NEXT ENTRY
  local current
  local next

  if [ ! -s "$TVA_PENDING_FILE" ]; then
    printf 'No pending manual steps.\n'
    : > "$TVA_CURRENT_FILE"
    return 0
  fi

  current="$(head -n 1 "$TVA_CURRENT_FILE")"
  # find the line after this one
  local found=0
  next=
  if [ -n "$current" ]; then
    while IFS= read -r line; do
      [ "$found" = 1 ] && { next="$line"; break; }
      [ "$line" = "$current" ] && found=1
    done < "$TVA_PENDING_FILE"
  fi
  [ -n "$next" ] || next="$(head -n 1 "$TVA_PENDING_FILE")"

  printf '%s\n' "$next" > "$TVA_CURRENT_FILE"

# PRINTING THE NEXT ENTRY
  local key="$next"
  local file
  local current_id
  local body
  found=0

  local project_dir
  for project_dir in "$REPO_ROOT"/*/; do
    [ -d "$project_dir" ] || continue
    file="$project_dir/$MANUAL_STEPS_FILENAME"
    [ -f "$file" ] || continue

   current_id=""
   body=""

   while IFS= read -r line || [ -n "$line" ]; do
     if [ -z "$line" ]; then
       if [ "$current_id" = "$key" ]; then
         found=1
         break
       fi
       current_id=""
       body=""
       continue
     fi

     case "$line" in
       'id: '*)
         current_id="${line#id: }"
         ;;
       'body: '*)
         if [ "$current_id" = "$key" ]; then
           body="${line#body: }"
         fi
         ;;
     esac
   done < "$file"

   if [ "$found" -eq 1 ] || [ "$current_id" = "$key" ]; then
     printf '\n'
     printf 'Step: %s\n' "$key"
     printf '\n'
     printf '%s\n' "$body"
     printf '\n'
     printf 'Command: tva manual done\n'
     printf '\n'
     return 0
   fi
 done
fail "manual step not found: $key"
}
