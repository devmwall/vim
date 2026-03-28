# dev-machine-setup

Small, practical setup repo for provisioning developer CLI environments across:

- macOS
- Linux
- Windows

This repo is intentionally simple. It is **not** a dotfiles framework, sync engine, or configuration management platform.

## What it does

- Detects current OS (`macos`, `linux`, or `windows`)
- Bootstraps a curated set of CLI tools for the detected OS
- Applies selected config files from this repo onto your machine
- Shows status of config entries relevant to your current OS

## Supported package managers

- macOS: Homebrew (`brew`)
- Linux: `apt-get`
- Windows: `winget`

If the required package manager is missing, bootstrap exits with a clear error.

## Repository layout

```text
.
├─ README.md
├─ manifest.json
├─ scripts/
│  ├─ setup.py
│  ├─ bootstrap.sh
│  ├─ bootstrap.ps1
│  ├─ apply.sh
│  └─ apply.ps1
├─ packages/
│  ├─ common.txt
│  ├─ macos.txt
│  ├─ linux.txt
│  └─ windows.txt
└─ dotfiles/
   ├─ shared/
   │  ├─ git/.gitconfig
   │  └─ nvim/init.lua
   ├─ macos/
   │  └─ zsh/.zshrc
   ├─ linux/
   │  ├─ bash/.bashrc
   │  └─ zsh/.zshrc
   └─ windows/
      ├─ powershell/Microsoft.PowerShell_profile.ps1
      └─ git/.gitconfig.windows
```

## Usage

Run from repo root:

```bash
python scripts/setup.py detect
python scripts/setup.py status
python scripts/setup.py bootstrap
python scripts/setup.py apply
```

Convenience wrappers:

```bash
bash scripts/apply.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1
```

## Verify installed tools

```bash
rg --version
fd --version
fzf --version
nvim --version
git --version
```

## Important note

This repo copies config files **from repo to machine only**.
It does **not** sync machine changes back into the repo.
