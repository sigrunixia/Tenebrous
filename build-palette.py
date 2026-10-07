#!/usr/bin/env python3
"""Generate the palette-driven files from shared/palette.json.

  <obsidian>/src/lib/_palette.scss  SCSS variables for the Obsidian theme (core colours)
  <site>/theme/src/_site-palette.scss  SCSS variables for the Quartz site's own colours (the site group)
  <zed>/themes/tenebrous.json    templates/zed.template.json with {{name}} and
                                 {{name:AA}} (alpha hex suffix) filled in

  <ghostty>/Tenebrous            Ghostty theme from templates/ghostty.template
  <fish>/Tenebrous.theme         fish theme from templates/fish.template
  <starship>/starship.toml       Starship config from templates/starship.template
  ./fzf-colors                   fzf --color option string from templates/fzf.template
                                 ({{name:bare}} writes the hex without the leading #)

  palette.svg                    swatch image of every colour, shown in the README

Repo paths come from OBSIDIAN_REPO, SITE_REPO, ZED_REPO, GHOSTTY_REPO, FISH_REPO and STARSHIP_REPO, set in .env and passed by build.sh.
"""
import os
import json, re, sys
from pathlib import Path

root = Path(__file__).resolve().parent
obsidian = Path(os.environ["OBSIDIAN_REPO"]) if os.environ.get("OBSIDIAN_REPO") else None
site = Path(os.environ["SITE_REPO"]) if os.environ.get("SITE_REPO") else None
zed = Path(os.environ["ZED_REPO"]) if os.environ.get("ZED_REPO") else None
ghostty = Path(os.environ["GHOSTTY_REPO"]) if os.environ.get("GHOSTTY_REPO") else None
fish = Path(os.environ["FISH_REPO"]) if os.environ.get("FISH_REPO") else None
starship = Path(os.environ["STARSHIP_REPO"]) if os.environ.get("STARSHIP_REPO") else None
pal = json.loads((root / "palette.json").read_text())
flat = {k: v for g in pal.values() for k, v in g.items()}

if obsidian:
    scss = "// Generated from shared/palette.json by shared/build-palette.py. Do not edit.\n"
    scss += "".join(f"${k}: {v};\n" for k, v in pal["core"].items())
    (obsidian / "src/lib/_palette.scss").write_text(scss)

if site:
    scss = "// Generated from palette.json by build-palette.py in Tenebrous. Do not edit.\n"
    scss += "".join(f"${k}: {v};\n" for k, v in pal["site"].items())
    (site / "theme/src/_site-palette.scss").write_text(scss)

def fill(m):
    name, _, mod = m.group(1).partition(":")
    if name not in flat:
        sys.exit(f"Unknown palette colour: {name}")
    return flat[name][1:] if mod == "bare" else flat[name] + mod

if zed:
    tpl = (root / "templates/zed.template.json").read_text()
    (zed / "themes").mkdir(exist_ok=True)
    (zed / "themes/tenebrous.json").write_text(re.sub(r"\{\{([^}]+)\}\}", fill, tpl))

for tpl_name, repo, out in (("ghostty.template", ghostty, "Tenebrous"), ("fish.template", fish, "Tenebrous.theme"), ("starship.template", starship, "starship.toml")):
    if not repo:
        continue
    dest = repo / out
    dest.write_text(re.sub(r"\{\{([^}]+)\}\}", fill, (root / "templates" / tpl_name).read_text()))

(root / "fzf-colors").write_text(re.sub(r"\{\{([^}]+)\}\}", fill, (root / "templates/fzf.template").read_text()) + "\n")

def luminance(h):
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (1, 3, 5))
    lin = [c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4 for c in (r, g, b)]
    return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]

cols, w, h, gap, pad = 5, 176, 96, 12, 24
groups = [("Core", pal["core"]), ("Zed only", pal["zed"]), ("Site only", pal["site"])]
y = pad
body = []
for title, colours in groups:
    body.append(f'<text x="{pad}" y="{y + 14}" fill="#a6accd" font-size="16" font-weight="700">{title}</text>')
    y += 28
    for i, (name, hexv) in enumerate(colours.items()):
        x = pad + (i % cols) * (w + gap)
        yy = y + (i // cols) * (h + gap)
        ink = "#14161b" if luminance(hexv) > 0.25 else "#e2e7f2"
        body.append(
            f'<rect x="{x}" y="{yy}" width="{w}" height="{h}" rx="8" fill="{hexv}" stroke="#242838"/>'
            f'<text x="{x + 12}" y="{yy + 36}" fill="{ink}" font-size="15" font-weight="700">{name}</text>'
            f'<text x="{x + 12}" y="{yy + 58}" fill="{ink}" font-size="13">{hexv}</text>'
        )
    y += ((len(colours) + cols - 1) // cols) * (h + gap) + 12
width = pad * 2 + cols * w + (cols - 1) * gap
svg = (
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{y + pad - 12}" '
    f'viewBox="0 0 {width} {y + pad - 12}" font-family="ui-monospace, Menlo, monospace">'
    f'<rect width="100%" height="100%" fill="#14161b"/>' + "".join(body) + "</svg>\n"
)
(root / "palette.svg").write_text(svg)
