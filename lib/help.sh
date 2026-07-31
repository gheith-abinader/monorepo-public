usage() {
  cat <<'USAGE'
tva - TechValuRythm monorepo CLI

Usage:
  tva list [--format text|json]
  tva install <project...>
  tva config <project> <config_file_path>
  tva manual add <project> <stepname_no_spaces>
  tva manual next
  tva manual done
  tva --help
USAGE
}
