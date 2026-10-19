usage() {
  cat <<'USAGE'

Usage:
  devflow list [--format text|json]
  devflow install <project...>
  devflow config [edit] <project> <config_file_path>
  devflow config apply <project> <config_file_path>
  devflow manual add <project> <stepname_no_spaces>
  devflow manual next
  devflow manual done
  devflow new devcontainer <project-name>
  devflow --help

Host-only command:
  devflow new devcontainer <project-name>
      Create a project at the monorepo root from shared/templates/.devcontainer
      and link the shared DevFlow directory into the new project.

Config commands:
  devflow config [edit] <project> <config_file_path>
      Open a project definition in the installer app and verify it against
      the current machine state.

  devflow config apply <project> <config_file_path>
      Apply a project definition to the installed Unix machine.
USAGE
}
