#!/usr/bin/env python3
import json
import pathlib
import sys

theme_dir = pathlib.Path(sys.argv[1])
themes = []
for path in sorted(theme_dir.glob("*.json")):
    if path.name == "template.json":
        continue
    try:
        palette = json.loads(path.read_text())
        themes.append({
            "id": "file:" + str(path),
            "name": path.stem.replace("-", " ").replace("_", " ").title(),
            "path": str(path),
            "bg": palette.get("background", "#070B0D"),
            "accent": palette.get("accent", "#67B0E8"),
        })
    except (OSError, ValueError, TypeError):
        pass
print(json.dumps(themes))
