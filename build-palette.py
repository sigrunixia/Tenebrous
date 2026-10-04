#!/usr/bin/env python3
"""Generate the palette-driven files from shared/palette.json.

  <obsidian>/src/_palette.scss   SCSS variables for the Obsidian theme (core colours)
  <zed>/themes/tenebrous.json    templates/zed.template.json with {{name}} and
                                 {{name:AA}} (alpha hex suffix) filled in

Repo paths come from OBSIDIAN_REPO and ZED_REPO.
"""
import os
import json, re, sys
from pathlib import Path

root = Path(__file__).resolve().parent
dev = Path(os.environ.get("DEVELOPER", "/Users/Signia/Developer"))
obsidian = Path(os.environ.get("OBSIDIAN_REPO", dev / "Tenebrous-Obsidian"))
zed = Path(os.environ.get("ZED_REPO", dev / "Tenebrous-Zed"))
pal = json.loads((root / "palette.json").read_text())
flat = {k: v for g in pal.values() for k, v in g.items()}

scss = "// Generated from shared/palette.json by shared/build-palette.py. Do not edit.\n"
scss += "".join(f"${k}: {v};\n" for k, v in pal["core"].items())
(obsidian / "src/_palette.scss").write_text(scss)

def fill(m):
    name, _, alpha = m.group(1).partition(":")
    if name not in flat:
        sys.exit(f"Unknown palette colour: {name}")
    return flat[name] + alpha

tpl = (root / "templates/zed.template.json").read_text()
(zed / "themes").mkdir(exist_ok=True)
(zed / "themes/tenebrous.json").write_text(re.sub(r"\{\{([^}]+)\}\}", fill, tpl))
