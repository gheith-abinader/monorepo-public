#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

REPO_ROOT="__REPO_ROOT__"
TVA_HOME="${HOME}/.tva"
TVA_PENDING_FILE="${TVA_HOME}/pending_manual_steps"
TVA_CURRENT_FILE="${TVA_HOME}/current_manual_step"
MANUAL_STEPS_FILENAME="MANUAL_STEPS"
DOTFILES_DIRNAME="dotfiles"

# General utilities
fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

. "$SCRIPT_DIR/tvaLib/help.sh"
. "$SCRIPT_DIR/tvaLib/list.sh"
. "$SCRIPT_DIR/tvaLib/manual.add.sh"
. "$SCRIPT_DIR/tvaLib/manual.next.sh"
. "$SCRIPT_DIR/tvaLib/manual.done.sh"
. "$SCRIPT_DIR/tvaLib/config.open.sh"
. "$SCRIPT_DIR/tvaLib/config.apply.sh"
. "$SCRIPT_DIR/tvaLib/install.sh"

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
      [ $# -gt 0 ] || fail "usage: tva install <project...>"
      for project in "$@"; do
        install_project "$project"
      done
      ;;
    config)
      shift

      if [ "${1-}" = "apply" ]; then
        shift
        [ $# -eq 2 ] || fail "usage: tva config apply <project> <config_file_path>"
        project="$1"
        config_file="$2"
        config_apply "$project" "$config_file"
      else
        if [ "${1-}" = "edit" ]; then
          shift
        fi

        [ $# -eq 2 ] || fail "usage: tva config [edit] <project> <config_file_path>"
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
          [ $# -eq 2 ] || fail "usage: tva manual add <project> <stepname_no_spaces>"
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
          fail "usage: tva manual <add|next|done>"
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
