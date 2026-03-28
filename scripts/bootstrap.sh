#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <macos|linux>" >&2
  exit 1
fi

TARGET_OS="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

COMMON_PACKAGES_FILE="${REPO_ROOT}/packages/common.txt"
MACOS_PACKAGES_FILE="${REPO_ROOT}/packages/macos.txt"
LINUX_PACKAGES_FILE="${REPO_ROOT}/packages/linux.txt"

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[error] Required command not found: $cmd" >&2
    exit 1
  fi
}

install_package_brew() {
  local pkg="$1"
  echo "[install] brew install ${pkg}"
  if brew install "$pkg"; then
    echo "[ok] ${pkg}"
  else
    echo "[skip] Failed or unavailable: ${pkg}"
  fi
}

install_package_apt() {
  local pkg="$1"
  echo "[install] apt-get install ${pkg}"
  if sudo apt-get install -y "$pkg"; then
    echo "[ok] ${pkg}"
  else
    echo "[skip] Failed or unavailable: ${pkg}"
  fi
}

install_from_file() {
  local file="$1"
  local installer="$2"

  if [[ ! -f "$file" ]]; then
    echo "[warn] Package list not found: $file"
    return
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    local pkg
    pkg="$(printf '%s' "$line" | xargs)"
    if [[ -z "$pkg" || "$pkg" == \#* ]]; then
      continue
    fi
    "$installer" "$pkg"
  done < "$file"
}

case "$TARGET_OS" in
  macos)
    require_command brew
    install_from_file "$COMMON_PACKAGES_FILE" install_package_brew
    install_from_file "$MACOS_PACKAGES_FILE" install_package_brew
    ;;
  linux)
    require_command apt-get
    require_command sudo
    echo "[info] Running apt-get update"
    sudo apt-get update
    install_from_file "$COMMON_PACKAGES_FILE" install_package_apt
    install_from_file "$LINUX_PACKAGES_FILE" install_package_apt
    ;;
  *)
    echo "[error] Unsupported target OS: ${TARGET_OS}" >&2
    exit 1
    ;;
esac

echo "[done] bootstrap completed for ${TARGET_OS}"
