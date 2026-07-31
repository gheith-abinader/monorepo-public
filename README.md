# IT TechValurythm Inc. — Monorepo

This is the monorepo of IT TechValurythm Inc. It hosts internal projects, setup scripts, and shared tooling under a single repository. The tva CLI, a Go-based tool, is the entry point for discovering projects, running installers, and tracking pending manual steps.

It is currently used to set up a developer machine on macOS and to install any project-related dependencies, providing a consistent and reproducible environment from a single entry point.

Unlike traditional configuration management tools (e.g., Ansible), this approach avoids maintaining complex declarative state or opaque automation layers. Instead, tva favors a transparent, developer-controlled workflow: configuration files stored in the repository are treated as the source of truth, and any divergence on the local machine is detected through an integrity check.

When differences are found, tva performs a vimdiff comparison between the repository definition and the local file, allowing precise, line-by-line reconciliation. This ensures that any additions or modifications made locally are explicitly reviewed and resolved, rather than silently overridden.

> ⚠️ **Supported platforms (current goal):** Unix-like systems with maximum shell compatibility, especially Bash 3 on macOS.

---

## Getting Started

### Local Setup

1. **Install GitHub CLI** if it is not already installed.

2. **Clone the repository:**

   ```bash
   gh repo clone gheith-abinader/monorepo
   cd monorepo
   ```

3. **Run the bootstrap script:**

   ```bash
   ./bootstrap.sh
   ```

   The bootstrap script installs the global `tva` wrapper in `/usr/local/bin/tva`, points it at the current repository path, and initializes TVA local state under `~/.tva/` if needed. Re-running `./bootstrap.sh` must not delete existing local TVA state.

4. **Discover available projects:**

   ```bash
   tva list
   ```

5. **Install a project:**

   ```bash
   tva install <project-name>
   ```

---

## Repository Structure

```text
monorepo/
├── bootstrap.sh          # First-run setup: installs tva globally
└── <project>/            # One folder per install project
    ├── MANUAL_STEPS      # Optional manual-step definitions for the project
    ├── dotfiles/         # Optional config assets owned by the project
    └── *.sh              # Main installer scripts for that project
```

Each project mainly contains one or more `.sh` installer files.

A project may also optionally contain:

- a `MANUAL_STEPS` file for manual setup steps,
- a `dotfiles/` directory for config assets.

Each `.sh` file is:

- **Self-contained** — no dependencies on sibling files.
- **Idempotent** — safe to run multiple times without side effects.
- **Responsible for its own config contributions** — declares exactly what it needs inline in the script and uses any config assets stored under its own `dotfiles/` directory.

Manual-step definitions and config assets remain encapsulated with the project in Git.

---

## Config Management

TVA manages program configuration through per-project config assets stored in that project's `dotfiles/` directory.

### Storage Location

Each project may contain a `dotfiles/` directory whose files map directly to target dotfiles. For example, `dotfiles/.zshrc` corresponds to `~/.zshrc`. The files inside `dotfiles/` are the target dotfiles themselves, so the filename is the important part.

Inside each local file, TVA can store a small header section first, then the real content begins on a later line. For example, the file may start with `location: ~/.zshrc`, then a `contents:` marker, and the real content begins on the next line. This keeps install logic in the shell scripts and configuration payloads in tracked files that are easy to diff, refresh, and review.

### Install-Time Behaviour

At install time, TVA should treat config files in two broad ways:

| Scenario | Behaviour |
|---|---|
| Target config does not exist, or exists but is empty | TVA may create or refresh the target config file directly. |
| Target config already exists and is non-empty | TVA should preserve it and ensure the original file loads a separate TVA-managed file through source chaining or an include mechanism when the program supports that pattern. |

For shell configs such as `.zshrc` or `.bashrc`, the common source-chaining pattern is to append a line that loads a separate TVA-managed file only if it exists.

### Source-Chaining Pattern

When TVA must preserve an existing config file, it should avoid overwriting the original file and instead attach its own managed config at the end. For example:

```bash
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
```

Before appending this source line, TVA checks whether the exact source-chaining instruction is already present. If `tva install <project>` is run again without an uninstall, TVA refreshes the redirected managed file but does not append the same source line a second time.

### Reinstall and Uninstall

TVA is **not** an uninstall manager and does not provide or manage an uninstall process. If a user chooses to uninstall a program and later reinstall it, the user is responsible for removing that program's dotfiles before reinstalling.

The only repeated-install safeguard in scope is idempotence: running `tva install <project>` more than once must not duplicate source-chaining instructions in an existing original dotfile.

### Phase-1 Scope

In phase 1, each project owns its own config scope and overlap between projects is explicitly out of scope. TVA does not need central conflict resolution yet; the user is responsible for ensuring that two different projects do not both claim the same target config area.

---

## `tva` CLI

`tva` is the TechValuRythm monorepo CLI. It is installed globally by `bootstrap.sh` and can be called from any directory once bootstrap completes.

### Commands

| Command | Description | Examples |
|---|---|---|
| `tva list` | List all projects in the monorepo that expose a setup definition. | `tva list` · `tva list --format json` |
| `tva install <project...>` | Install dependencies for one or more projects. | `tva install api` · `tva install api web` |
| `tva manual add <project> <stepname_no_spaces>` | Add a manual-step definition entry to a project's `MANUAL_STEPS` file. | `tva manual add macos dock-reset` |
| `tva manual next` | Show the full details of the next pending manual step. | `tva manual next` |
| `tva manual done` | Mark the current manual step as completed by removing it from pending state. | `tva manual done` |

The current bootstrap-installed `tva` wrapper provides `list`, `install`, `manual add`, `manual next`, and `manual done` in its embedded usage text and command dispatcher. The README only documents commands that exist in the current `bootstrap.sh` implementation.

### Manual Steps

TVA supports install steps that are easier to complete manually than to automate. Each project may define those steps inside a `MANUAL_STEPS` file stored in the project folder, and `tva install <project>` enqueues those step IDs into local pending state under `~/.tva/` on the current machine.

TVA stores only pending manual-step state locally and does not persist a global install history or a completed-step archive.

### Manual-Step Workflow

1. Define manual steps inside a project folder.
2. Run `tva install <project>`.
3. TVA finishes the automated install and alerts you if manual steps are pending.
4. Run `tva manual next` to view the next pending step in full detail.
5. Run `tva manual done` to remove the current step from pending state.

### Arguments

| Argument | Description | Commands | Examples |
|---|---|---|---|
| `<project...>` | One or more project names to install. | `install` | `tva install api` |
| `--help` or `-h` | Show help for the current command. | all | `tva --help` |

### Global Flags

| Flag | Description |
|---|---|
| `-h`, `--help` | Show help for the current command. |

### `list` Flags

| Flag | Description | Examples |
|---|---|---|
| `--format text` | Output project list in human-readable text. | `tva list --format text` |
| `--format json` | Output project list in machine-readable JSON. | `tva list --format json` |

---

## Error Behavior

`install` stops immediately on the first error because the bootstrap-installed CLI and installer scripts use strict shell settings and explicit failure paths. Errors should be printed as clear human-readable messages to `stderr`, and successful installs should still alert the user if pending manual action remains.

### Exit Codes

| Code | Meaning |
|---|---|
| `0` | Command completed successfully. |
| `1` | Installation failed at runtime. |
| `2` | Usage error, such as an unknown command or missing required argument. |
| `130` | Command was interrupted by Ctrl+C. |

---

## Usage Examples

### Discover available projects

```bash
tva list
tva list --format text
tva list --format json
```

### Install one or more projects

```bash
tva install api
tva install web
```

### Work through manual steps

```bash
tva manual next
tva manual done
```

### Get help

```bash
tva --help
```
