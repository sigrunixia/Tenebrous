#!/usr/bin/env python3
"""Generate the palette-driven files from shared/palette.json.

  <obsidian>/src/lib/_palette.scss  SCSS variables for the Obsidian theme (core colours)
  <zed>/themes/tenebrous.json    templates/zed.template.json with {{name}} and
                                 {{name:AA}} (alpha hex suffix) filled in. The Zed-only
                                 colours come from <zed>/palette.json, not from here

  <ghostty>/Tenebrous            Ghostty theme from templates/ghostty.template
  <fish>/Tenebrous.theme         fish theme from templates/fish.template
  <starship>/starship.toml       Starship config from templates/starship.template
  ./fzf-colors                   fzf --color option string from templates/fzf.template
                                 ({{name:bare}} writes the hex without the leading #)

  palette.svg                    swatch image of every colour, shown in the README

Repo paths come from OBSIDIAN_REPO, ZED_REPO, GHOSTTY_REPO, FISH_REPO and STARSHIP_REPO, set in .env and passed by build.sh.
"""
import os
import json, math, re, sys
from pathlib import Path

root = Path(__file__).resolve().parent
obsidian = Path(os.environ["OBSIDIAN_REPO"]) if os.environ.get("OBSIDIAN_REPO") else None
zed = Path(os.environ["ZED_REPO"]) if os.environ.get("ZED_REPO") else None
ghostty = Path(os.environ["GHOSTTY_REPO"]) if os.environ.get("GHOSTTY_REPO") else None
fish = Path(os.environ["FISH_REPO"]) if os.environ.get("FISH_REPO") else None
starship = Path(os.environ["STARSHIP_REPO"]) if os.environ.get("STARSHIP_REPO") else None
def oklch_to_hex(text):
    """Turn "oklch(L C H)" into a hex colour. A colour outside sRGB loses chroma until it fits."""
    L, C, H = (float(x) for x in re.match(r"oklch\(\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)\s*\)", text).groups())
    def rgb(c):
        a, b = c * math.cos(math.radians(H)), c * math.sin(math.radians(H))
        l, m, s = (L + 0.3963377774*a + 0.2158037573*b) ** 3, (L - 0.1055613458*a - 0.0638541728*b) ** 3, (L - 0.0894841775*a - 1.2914855480*b) ** 3
        return (4.0767416621*l - 3.3077115913*m + 0.2309699292*s, -1.2684380046*l + 2.6097574011*m - 0.3413193965*s, -0.0041960863*l - 0.7034186147*m + 1.7076147010*s)
    lo, hi = 0.0, C
    if not all(-0.0005 <= x <= 1.0005 for x in rgb(C)):
        for _ in range(40):
            mid = (lo + hi) / 2
            lo, hi = (mid, hi) if all(-0.0005 <= x <= 1.0005 for x in rgb(mid)) else (lo, mid)
        C = lo
    enc = lambda x: 12.92 * x if x <= 0.0031308 else 1.055 * max(x, 0) ** (1 / 2.4) - 0.055
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(enc(x) * 255))) for x in rgb(C))

def hexes(colours):
    return {k: oklch_to_hex(v) if v.startswith("oklch") else v for k, v in colours.items()}

pal = json.loads((root / "palette.json").read_text())
pal = {group: hexes(colours) for group, colours in pal.items()}
flat = {k: v for g in pal.values() for k, v in g.items()}

if obsidian:
    scss = "// Generated from shared/palette.json by shared/build-palette.py. Do not edit.\n"
    scss += "".join(f"${k}: {v};\n" for k, v in pal["core"].items())
    (obsidian / "src/lib/_palette.scss").write_text(scss)

def filler(colours):
    def fill(m):
        name, _, mod = m.group(1).partition(":")
        if name not in colours:
            sys.exit(f"Unknown palette colour: {name}")
        return colours[name][1:] if mod == "bare" else colours[name] + mod
    return fill
fill = filler(flat)

if zed:
    tpl = (root / "templates/zed.template.json").read_text()
    (zed / "themes").mkdir(exist_ok=True)
    # The Zed-only colours (the dim terminal shades) live in the Zed repo.
    extras = json.loads((zed / "palette.json").read_text()) if (zed / "palette.json").exists() else {}
    (zed / "themes/tenebrous.json").write_text(re.sub(r"\{\{([^}]+)\}\}", filler({**flat, **extras}), tpl))

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
groups = [("Core", pal["core"]), ("Terminals", pal["terminal"])]
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
