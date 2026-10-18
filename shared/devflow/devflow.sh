#!/usr/bin/env bash
set -euo pipefail

DEVFLOW_INSTALL_DIR="/opt/devflow"
DEVFLOW_LIB_DIR="$DEVFLOW_INSTALL_DIR/lib"

# guarded assignement in case we want to override the default location of devflow home directory from environment variable
DEVFLOW_HOME="${DEVFLOW_HOME:-${HOME}/.devflow}"
DEVFLOW_PENDING_FILE="${DEVFLOW_HOME}/pending_manual_steps"
DEVFLOW_CURRENT_FILE="${DEVFLOW_HOME}/current_manual_step"

PROJECTS_DIR="__PROJECTS_DIR__" # this is replaced by the actual feature directory path during installation 

MANUAL_STEPS_FILENAME="MANUAL_STEPS"
DOTFILES_DIRNAME="dotfiles"

mkdir -p "$DEVFLOW_HOME"

[[ -f "$DEVFLOW_PENDING_FILE" ]] || touch "$DEVFLOW_PENDING_FILE"
[[ -f "$DEVFLOW_CURRENT_FILE" ]] || touch "$DEVFLOW_CURRENT_FILE"

# General utilities
fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

. "$DEVFLOW_LIB_DIR/help.sh"
. "$DEVFLOW_LIB_DIR/list.sh"
. "$DEVFLOW_LIB_DIR/manual.add.sh"
. "$DEVFLOW_LIB_DIR/manual.next.sh"
. "$DEVFLOW_LIB_DIR/manual.done.sh"
. "$DEVFLOW_LIB_DIR/config.open.sh"
. "$DEVFLOW_LIB_DIR/config.apply.sh"
. "$DEVFLOW_LIB_DIR/install.sh"

#main
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
      for project in "$@"; do
        install_project "$project"
      done
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
        if [ "${1-}" = "edit" ]; then
          shift
        fi

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
        next)
          shift
          cmd_manual_next "$@"
          ;;
        done)
          shift
          cmd_manual_done "$@"
          ;;
        *)
          fail "usage: devflow manual <add|next|done>"
          ;;
      esac
      ;;
    -h|--help|"")
      usage
      ;;
    *)
      fail "unknown command: $cmd"
      ;;
  esac
}

main "$@"
