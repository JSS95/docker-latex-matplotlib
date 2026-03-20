import json
import os
import sys
from pathlib import Path


def parse_python_version(value: str) -> tuple[int, ...]:
    return tuple(int(part) for part in value.split("."))


def main() -> int:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: resolve_versions.py <config-path>")

    config_path = Path(sys.argv[1])
    config = json.loads(config_path.read_text(encoding="utf-8"))

    python_versions = config["python_versions"]
    texlive_versions = config["texlive_versions"]

    latest_python_version = max(python_versions, key=parse_python_version)
    latest_texlive_version = max(texlive_versions, key=int)

    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
        output.write(f"python_versions={json.dumps(python_versions)}\n")
        output.write(f"texlive_versions={json.dumps(texlive_versions)}\n")
        output.write(f"latest_python_version={latest_python_version}\n")
        output.write(f"latest_texlive_version={latest_texlive_version}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())