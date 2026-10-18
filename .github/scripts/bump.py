"""Point Formula/qavf.rb at the latest QAVF release on PyPI.

Standard library only. Writes ``changed`` and ``version`` to ``$GITHUB_OUTPUT``.
The formula only moves forward, and only to a release that publishes an sdist.
"""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.request
from pathlib import Path

FORMULA = Path("Formula/qavf.rb")
URL = re.compile(r'^(\s*url ")[^"]+(")$', re.MULTILINE)
SHA = re.compile(r'^(\s*sha256 ")[0-9a-f]{64}(")$', re.MULTILINE)
VERSION = re.compile(r"/qavf-(\d+(?:\.\d+)*)\.tar\.gz\"$", re.MULTILINE)


def _key(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in version.split("."))


def _output(**values: str) -> None:
    target = os.environ.get("GITHUB_OUTPUT")
    lines = "".join(f"{key}={value}\n" for key, value in values.items())
    if target:
        with open(target, "a", encoding="utf-8") as handle:
            handle.write(lines)
    print(lines, end="")


def main() -> int:
    with urllib.request.urlopen("https://pypi.org/pypi/qavf/json", timeout=30) as response:
        release = json.load(response)
    latest = release["info"]["version"]
    if not re.fullmatch(r"\d+(?:\.\d+)*", latest):
        print(f"Ignoring non-final release {latest}")
        _output(changed="false", version=latest)
        return 0
    sdist = next(
        (item for item in release["urls"] if item["packagetype"] == "sdist" and not item["yanked"]),
        None,
    )
    if sdist is None:
        raise SystemExit(f"qavf {latest} has no sdist on PyPI")
    text = FORMULA.read_text(encoding="utf-8")
    current = VERSION.search(text)
    if current is None or len(URL.findall(text)) != 1 or len(SHA.findall(text)) != 1:
        raise SystemExit("Formula must contain exactly one PyPI sdist url and sha256")
    if _key(latest) <= _key(current.group(1)):
        print(f"Formula already at {current.group(1)} (latest {latest})")
        _output(changed="false", version=current.group(1))
        return 0
    text = URL.sub(rf'\g<1>{sdist["url"]}\g<2>', text)
    text = SHA.sub(rf'\g<1>{sdist["digests"]["sha256"]}\g<2>', text)
    FORMULA.write_text(text, encoding="utf-8", newline="\n")
    print(f"Updated formula {current.group(1)} -> {latest}")
    _output(changed="true", version=latest)
    return 0


if __name__ == "__main__":
    sys.exit(main())
