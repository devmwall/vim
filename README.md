# dev-machine-setup

Small, practical setup repo for provisioning developer CLI environments on macOS, Linux, and Windows.

This repo is intentionally simple. It is **not** a dotfiles framework, sync engine, or configuration management platform.

## What this repo does

- Detects the current OS (`macos`, `linux`, or `windows`)
- Bootstraps a curated set of CLI tools for that OS
- Applies selected config files from this repo to your machine
- Captures selected config files from your machine back into this repo
- Shows status for manifest entries relevant to the current OS

## Requirements

- `python` in `PATH`
- Package manager by platform:
  - macOS: Homebrew (`brew`)
  - Linux: `apt-get` (plus `sudo`)
  - Windows: `winget`

If a required package manager is missing, `bootstrap` exits with a clear error.

## Repository layout

```text
.
|- README.md
|- manifest.json
|- scripts/
|  |- setup.py
|  |- bootstrap.sh
|  |- bootstrap.ps1
|  |- apply.sh
|  |- apply.ps1
|  |- capture.sh
|  `- capture.ps1
|- packages/
|  |- common.txt
|  |- macos.txt
|  |- linux.txt
|  `- windows.txt
`- dotfiles/
   |- shared/
   |  |- git/.gitconfig
   |  `- nvim/init.lua
   |- macos/
   |  `- zsh/.zshrc
   |- linux/
   |  |- bash/.bashrc
   |  `- zsh/.zshrc
   `- windows/
      |- powershell/Microsoft.PowerShell_profile.ps1
      `- git/.gitconfig.windows
```

## Quick start

Run from the repo root:

```bash
python scripts/setup.py detect
python scripts/setup.py status
python scripts/setup.py bootstrap
python scripts/setup.py apply
```

Use `capture` when you want to pull local config changes back into this repo:

```bash
python scripts/setup.py capture
```

## Command reference

- `detect`: prints `macos`, `linux`, or `windows`
- `status`: shows manifest entries for your current OS and whether sources exist
- `bootstrap`: installs packages from `packages/common.txt` + your OS-specific package list
- `apply`: copies repo-managed files to their machine targets defined in `manifest.json`
- `capture`: copies machine files back into repo-managed sources from `manifest.json`

## Convenience wrappers

Shell wrappers:

```bash
bash scripts/bootstrap.sh macos   # or linux
bash scripts/apply.sh
bash scripts/capture.sh
```

PowerShell wrappers:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/bootstrap.ps1
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1
powershell -ExecutionPolicy Bypass -File scripts/capture.ps1
```

## Verify installed tools

```bash
rg --version
fd --version
fzf --version
nvim --version
git --version
```

## Important behavior

- `apply` is repo -> machine
- `capture` is machine -> repo

There is no automatic or bidirectional sync. Both directions are explicit, one-shot copy operations.
