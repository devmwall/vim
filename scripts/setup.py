#!/usr/bin/env python3
import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST_PATH = REPO_ROOT / "manifest.json"


def detect_os() -> str:
    system = platform.system().lower()
    if system == "darwin":
        return "macos"
    if system == "linux":
        return "linux"
    if system == "windows":
        return "windows"
    raise RuntimeError(f"Unsupported platform: {platform.system()}")


def load_manifest() -> dict:
    if not MANIFEST_PATH.exists():
        raise FileNotFoundError(f"Manifest file not found: {MANIFEST_PATH}")
    with MANIFEST_PATH.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if "entries" not in data or not isinstance(data["entries"], list):
        raise ValueError("manifest.json must contain an 'entries' list")
    return data


def expand_user_path(path_str: str) -> Path:
    return Path(os.path.expanduser(path_str)).resolve()


def cmd_detect() -> int:
    os_name = detect_os()
    print(os_name)
    return 0


def cmd_status() -> int:
    os_name = detect_os()
    manifest = load_manifest()
    entries = [e for e in manifest["entries"] if os_name in e.get("os", [])]

    print(f"Detected OS: {os_name}")
    print(f"Relevant manifest entries: {len(entries)}")

    for entry in entries:
        name = entry.get("name", "<unnamed>")
        source_rel = entry.get("source")
        targets = entry.get("targets", {})
        target_raw = targets.get(os_name)

        source_abs = REPO_ROOT / source_rel if source_rel else None
        source_exists = bool(source_abs and source_abs.exists())

        print("-" * 60)
        print(f"name: {name}")
        print(f"source: {source_rel}")
        print(f"target: {target_raw}")
        print(f"source_exists: {'yes' if source_exists else 'no'}")

    return 0


def cmd_bootstrap() -> int:
    os_name = detect_os()
    print(f"[info] Detected OS: {os_name}")

    if os_name in {"macos", "linux"}:
        script = REPO_ROOT / "scripts" / "bootstrap.sh"
        cmd = ["bash", str(script), os_name]
    elif os_name == "windows":
        script = REPO_ROOT / "scripts" / "bootstrap.ps1"
        cmd = [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(script),
        ]
    else:
        print(f"[error] Unsupported platform: {os_name}", file=sys.stderr)
        return 1

    print(f"[info] Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=str(REPO_ROOT))
    return result.returncode


def cmd_apply() -> int:
    os_name = detect_os()
    manifest = load_manifest()

    copied = 0
    skipped = 0

    print(f"[info] Detected OS: {os_name}")

    for entry in manifest["entries"]:
        if os_name not in entry.get("os", []):
            continue

        name = entry.get("name", "<unnamed>")
        source_rel = entry.get("source")
        targets = entry.get("targets", {})
        target_raw = targets.get(os_name)

        if not source_rel or not target_raw:
            print(f"[skip] {name}: missing source or target in manifest")
            skipped += 1
            continue

        source_abs = (REPO_ROOT / source_rel).resolve()
        target_abs = expand_user_path(target_raw)

        if not source_abs.exists():
            print(f"[skip] {name}: source file does not exist: {source_abs}")
            skipped += 1
            continue

        target_abs.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_abs, target_abs)
        print(f"[copy] {name}: {source_abs} -> {target_abs}")
        copied += 1

    print(f"[done] copied={copied}, skipped={skipped}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Development machine setup tool")
    parser.add_argument(
        "command",
        choices=["detect", "status", "bootstrap", "apply"],
        help="Command to run",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    try:
        if args.command == "detect":
            return cmd_detect()
        if args.command == "status":
            return cmd_status()
        if args.command == "bootstrap":
            return cmd_bootstrap()
        if args.command == "apply":
            return cmd_apply()
    except Exception as exc:
        print(f"[error] {exc}", file=sys.stderr)
        return 1

    return 1


if __name__ == "__main__":
    sys.exit(main())
