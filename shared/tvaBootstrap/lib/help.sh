usage() {
  cat <<'USAGE'

Usage:
  tva list [--format text|json]
  tva install <project...>
  tva config [edit] <project> <config_file_path> # 'edit' is optional
  tva config apply <project> <config_file_path>
  tva manual add <project> <stepname_no_spaces>
  tva manual next
  tva manual done
  tva --help

Config commands:
  tva config [edit] <project> <config_file_path>
      Open a project definition in the installer app and verify it against
      the current machine state.

  tva config apply <project> <config_file_path>
      Apply a project definition to the installed Unix machine.
USAGE
}
