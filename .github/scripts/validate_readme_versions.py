import json
import sys
from pathlib import Path


EXPECTED_ROWS = {
    "Python": "python_versions",
    "TeXLive": "texlive_versions",
}


def load_supported_versions_table(readme_text: str) -> dict[str, str]:
    lines = readme_text.splitlines()

    try:
        start = lines.index("### Supported versions") + 1
    except ValueError as error:
        raise SystemExit("README.md is missing the '### Supported versions' section.") from error

    table_lines: list[str] = []
    for line in lines[start:]:
        if not line.strip():
            if table_lines:
                break
            continue
        if not line.startswith("|"):
            if table_lines:
                break
            continue
        table_lines.append(line)

    if len(table_lines) < 3:
        raise SystemExit("README.md Supported versions table is missing or incomplete.")

    parsed_rows: dict[str, str] = {}
    for line in table_lines[2:]:
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) != 2:
            raise SystemExit(f"README.md contains an invalid Supported versions row: {line}")
        dependency, version = cells
        parsed_rows[dependency] = version

    return parsed_rows


def format_versions(versions: list[str]) -> str:
    return ", ".join(f"`{version}`" for version in versions)


def main() -> int:
    if len(sys.argv) != 3:
        raise SystemExit("Usage: validate_readme_versions.py <versions-json> <readme>")

    versions_path = Path(sys.argv[1])
    readme_path = Path(sys.argv[2])

    versions_config = json.loads(versions_path.read_text(encoding="utf-8"))
    readme_rows = load_supported_versions_table(readme_path.read_text(encoding="utf-8"))

    mismatches: list[str] = []
    for dependency, config_key in EXPECTED_ROWS.items():
        expected = format_versions(versions_config[config_key])
        actual = readme_rows.get(dependency)
        if actual is None:
            mismatches.append(f"Missing README row for {dependency}.")
            continue
        if actual != expected:
            mismatches.append(
                f"{dependency} row mismatch: expected '{expected}', found '{actual}'."
            )

    extra_rows = sorted(set(readme_rows) - set(EXPECTED_ROWS))
    for dependency in extra_rows:
        mismatches.append(f"Unexpected README row in Supported versions table: {dependency}.")

    if mismatches:
        details = "\n".join(f"- {message}" for message in mismatches)
        raise SystemExit(
            "README.md Supported versions table does not match versions.json:\n"
            f"{details}"
        )

    print("README.md Supported versions table matches versions.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())