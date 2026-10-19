#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEVFLOW_INSTALL_DIR="${DEVFLOW_INSTALL_DIR:-/opt/devflow}"
[[ -d "$DEVFLOW_INSTALL_DIR/lib" ]] || DEVFLOW_INSTALL_DIR="$SCRIPT_DIR"
DEVFLOW_LIB_DIR="$DEVFLOW_INSTALL_DIR/lib"

DEVFLOW_HOME="${DEVFLOW_HOME:-${HOME}/.devflow}"
DEVFLOW_PENDING_FILE="${DEVFLOW_HOME}/pending_manual_steps"
DEVFLOW_CURRENT_FILE="${DEVFLOW_HOME}/current_manual_step"

MONOREPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
PROJECTS_DIR="__PROJECTS_DIR__"
[[ "$PROJECTS_DIR" != "__PROJECTS_DIR__" ]] || PROJECTS_DIR="$MONOREPO_ROOT"

MANUAL_STEPS_FILENAME="MANUAL_STEPS"
DOTFILES_DIRNAME="dotfiles"

mkdir -p "$DEVFLOW_HOME"
[[ -f "$DEVFLOW_PENDING_FILE" ]] || touch "$DEVFLOW_PENDING_FILE"
[[ -f "$DEVFLOW_CURRENT_FILE" ]] || touch "$DEVFLOW_CURRENT_FILE"

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

. "$DEVFLOW_LIB_DIR/help.sh"
. "$DEVFLOW_LIB_DIR/list.sh"
. "$DEVFLOW_LIB_DIR/manual.add.sh"
. "$DEVFLOW_LIB_DIR/manual.next.sh"
. "$DEVFLOW_LIB_DIR/manual.done.sh"
. "$DEVFLOW_LIB_DIR/config.open.sh"
. "$DEVFLOW_LIB_DIR/config.apply.sh"
. "$DEVFLOW_LIB_DIR/install.sh"

# BEGIN HOST-ONLY COMMAND
. "$DEVFLOW_LIB_DIR/new.devcontainer.sh"
# END HOST-ONLY COMMAND

main() {
  local cmd="${1:-}"
  local project
  local stepname

  case "$cmd" in
    list)
      shift
      list_projects "$@"
      ;;
    install)
      shift
      [ $# -gt 0 ] || fail "usage: devflow install <project...>"
      for project in "$@"; do install_project "$project"; done
      ;;
    config)
      shift
      if [ "${1-}" = "apply" ]; then
        shift
        [ $# -eq 2 ] || fail "usage: devflow config apply <project> <config_file_path>"
        project="$1"
        config_file="$2"
        config_apply "$project" "$config_file"
      else
        if [ "${1-}" = "edit" ]; then shift; fi
        [ $# -eq 2 ] || fail "usage: devflow config [edit] <project> <config_file_path>"
        project="$1"
        config_file="$2"
        config_open "$project" "$config_file"
      fi
      ;;
    manual)
      shift
      case "${1:-}" in
        add)
          shift
          [ $# -eq 2 ] || fail "usage: devflow manual add <project> <stepname_no_spaces>"
          project="$1"
          stepname="$2"
          manual_add "$project" "$stepname"
          ;;
        next) shift; cmd_manual_next "$@" ;;
        done) shift; cmd_manual_done "$@" ;;
        *) fail "usage: devflow manual <add|next|done>" ;;
      esac
      ;;
    # BEGIN HOST-ONLY COMMAND
    new)
      shift
      case "${1:-}" in
        devcontainer)
          shift
          [ $# -eq 1 ] || fail "usage: devflow new devcontainer <project-name>"
          new_devcontainer "$1"
          ;;
        *) fail "usage: devflow new devcontainer <project-name>" ;;
      esac
      ;;
    # END HOST-ONLY COMMAND
    -h|--help|"") usage ;;
    *) fail "unknown command: $cmd" ;;
  esac
}

main "$@"
