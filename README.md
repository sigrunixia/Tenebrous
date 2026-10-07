# Tenebrous

Tenebrous was initially inspired by [Poimandres](https://github.com/drcmda/poimandres-theme) and has grown into something more unique. Tenebrous is a dark color scheme. The background is a near-black blue and the text is a soft grey-purple. Amber is the main accent, used for links and headings. Blues, purples and greens cover the rest, with red and pink used sparingly. (But it is very pretty!)

![The Tenebrous palette](palette.svg)

## Themes

- [Tenebrous Obsidian](https://github.com/sigrunixia/Tenebrous-Obsidian), the theme for [Obsidian](https://obsidian.md/).
- [Tenebrous Zed](https://github.com/sigrunixia/Tenebrous-Zed), the theme for [Zed](https://zed.dev/).
- [Tenebrous Ghostty](https://github.com/sigrunixia/Tenebrous-Ghostty), the theme for [Ghostty](https://ghostty.org/).
- [Tenebrous Fish](https://github.com/sigrunixia/Tenebrous-Fish), the theme for [fish](https://fishshell.com/).
- [Tenebrous Starship](https://github.com/sigrunixia/Tenebrous-Starship), the config for the [Starship](https://starship.rs/) prompt.

## Colors


Each row says where a color shows up, and the color name is its key in `palette.json`. The contrast of each is measured against Background (`#0d0f14`) with the WCAG formula. AA needs 4.5 to 1 for normal text and AAA needs 7 to 1.

Every text color passes AA on Background, including Faint text (`comment`). On the lightest surface, Borders, hover and selected rows (`bg-highlight`), Faint text is still above 4.5 to 1.

I did not require AAA, because that much contrast is not something I need yet, and designing for it leads to many sites looking the same.

### Backgrounds

The contrast here is Text (`#c3c9e6`) sitting on each surface.

| Where it shows up | Color | Hex | Text contrast | WCAG |
|---|---|---|---|---|
| Background, the editor and the page | bg | `#0d0f14` | 11.70 | AAA |
| Sidebars, tabs and the title bar | bg-dark2 | `#080a0e` | 12.09 | AAA |
| Code blocks and the active line | bg-highlight-dk | `#131621` | 11.01 | AAA |
| Borders, hover and selected rows | bg-highlight | `#222740` | 8.95 | AAA |

### Text

| Where it shows up | Color | Hex | Contrast | WCAG |
|---|---|---|---|---|
| Text | fg | `#c3c9e6` | 11.70 | AAA |
| Muted text, punctuation and code comments | fg-dark | `#a6accd` | 8.58 | AAA |
| Faint text, placeholders and line numbers | comment | `#8c92b6` | 6.30 | AA |
| Bright text | silver | `#e2e7f2` | 15.47 | AAA |
| Nav item hover | unknown | `#ffffff` | 19.17 | AAA |

### Headings and links

| Where it shows up | Color | Hex | Contrast | WCAG |
|---|---|---|---|---|
| Header 1 | blue0 | `#7aa6e6` | 7.69 | AAA |
| Header 2 | amber | `#f0b04a` | 10.05 | AAA |
| Header 3 | teal | `#5fb8c8` | 8.38 | AAA |
| Header 4 | magenta | `#a894e8` | 7.36 | AAA |
| Header 5 | green | `#5de4c7` | 12.22 | AAA |
| Header 6 | silver | `#e2e7f2` | 15.47 | AAA |
| Bold | blue0 | `#7aa6e6` | 7.69 | AAA |
| Italic | amber | `#f0b04a` | 10.05 | AAA |
| Links | amber0 | `#e8a955` | 9.34 | AAA |
| Link hover | amber | `#f0b04a` | 10.05 | AAA |

### Code

| Where it shows up | Color | Hex | Contrast | WCAG |
|---|---|---|---|---|
| Keyword | magenta | `#a894e8` | 7.36 | AAA |
| Function | amber | `#f0b04a` | 10.05 | AAA |
| String | green | `#5de4c7` | 12.22 | AAA |
| Secondary string and escapes | green0 | `#5fb3a1` | 7.71 | AAA |
| Number | pink | `#f087bd` | 8.13 | AAA |
| Property and attribute | cyan | `#89ddff` | 12.64 | AAA |
| Operator and parameter | teal | `#5fb8c8` | 8.38 | AAA |
| Type and built-in | blue0 | `#7aa6e6` | 7.69 | AAA |
| Tag, boolean and constant | red | `#e47461` | 6.36 | AA |
| Value | yellow | `#fffac2` | 17.99 | AAA |
| URL | amber0 | `#e8a955` | 9.34 | AAA |

### Callouts and status

| Where it shows up | Color | Hex | Contrast | WCAG |
|---|---|---|---|---|
| Note | blue0 | `#7aa6e6` | 7.69 | AAA |
| Summary | cyan | `#89ddff` | 12.64 | AAA |
| Info | teal | `#5fb8c8` | 8.38 | AAA |
| Todo | silver | `#e2e7f2` | 15.47 | AAA |
| Tip | green | `#5de4c7` | 12.22 | AAA |
| Important | pink | `#f087bd` | 8.13 | AAA |
| Success | lime | `#a8d86e` | 11.60 | AAA |
| Question | yellow | `#fffac2` | 17.99 | AAA |
| Warning | orange | `#f5a04a` | 9.14 | AAA |
| Error | red | `#e47461` | 6.36 | AA |
| Deleted lines and error messages | red1 | `#f07a62` | 7.00 | AA |
| Fail | crimson | `#df6d7f` | 6.05 | AA |
| Bug | rose | `#d370a3` | 6.04 | AA |
| Example | magenta | `#a894e8` | 7.36 | AAA |

### Zed only

Zed needs an accent for the cursor and focus border, and dimmer shades for the terminal. These are interface and terminal colors, so the contrast is against Background.

| Where it shows up | Color | Hex | Contrast | WCAG |
|---|---|---|---|---|
| Cursor and focus border | accent | `#3980c6` | 4.63 | AA |
| Terminal dim red | red-dim | `#a8473a` | 3.31 | Large text and UI only |
| Terminal dim blue | blue-dim | `#5d7fb0` | 4.68 | AA |
| Terminal dim magenta | magenta-dim | `#8070b0` | 4.44 | Large text and UI only |
| Terminal dim cyan | cyan-dim | `#4a8f9c` | 5.20 | AA |

### Site only

The Quartz site has a few colors of its own, mostly edges and the contrast boosts for people who ask for more. They are written to the site's `theme/src/_site-palette.scss`. The contrast is against Background.

| Where it shows up | Color | Hex | Contrast | WCAG |
|---|---|---|---|---|
| Brown highlight | brown | `#b0825a` | 5.65 | AA |
| Field and button edge | edge | `#59607f` | 3.11 | UI only |
| Field and button edge, more contrast | edge-high | `#9aa1c4` | 7.55 | AAA |
| Faint text, more contrast | faint-high | `#b4bad8` | 10.00 | AAA |
| Secondary text, more contrast | text-high | `#d0d5ee` | 13.18 | AAA |
| Sidebar line in the shadow | shadow-line | `#1c202c` | 1.18 | Decoration only |

## Building

Every color lives in `palette.json`. Run `build.sh` and it writes the Obsidian palette file, the site's palette file, the Zed theme and `palette.svg` from it, so a color only ever gets changed in one place.

```
./build.sh --obsidian-theme        # theme.css and snippets
./build.sh --obsidian-publish-css  # publish.css
./build.sh --obsidian-publish-js   # publish.js
./build.sh --obsidian-push         # push publish.css and/or publish.js live
./build.sh --zed                   # Zed theme
./build.sh --ghostty               # Ghostty theme
./build.sh --fish                  # fish theme
./build.sh --starship              # Starship config
./build.sh --fzf                   # fzf colours
./build.sh --all                   # everything except the push
./build.sh --build-only            # build without deploying
```

Flags stack, so `./build.sh --obsidian-publish-css --obsidian-push` builds publish.css and pushes just that.

Copy `.env.example` to `.env` and point it at your repos and vault. The script reads it every run. Set `GHOSTTY_REPO`, `FISH_REPO` and `STARSHIP_REPO` for those. Starship deploys to `~/.config/starship.toml`, or `STARSHIP_CONFIG` if set, and overwrites it. The fzf colors build to `fzf-colors` and deploy to `~/.config/tenebrous/fzf-colors`, which `config.fish` and `.zshrc` read into `FZF_DEFAULT_OPTS`. Ghostty and fish deploy to `~/.config/ghostty/themes` and `~/.config/fish/themes`, or to `GHOSTTY_THEMES` and `FISH_THEMES` if you set those. Change the Zed template, not the Zed theme it spits out, because the next build writes over it.

## Special thanks

- [Poimandres](https://github.com/drcmda/poimandres-theme) by drcmda, the original theme that inspired this
- [Poimandres for Obsidian](https://github.com/yoGhastly/poimandres-obsidian) by yoGhastly, where the Obsidian theme started
- [Dbarenholz](https://github.com/dbarenholz) for dealing with me on [halcyon-obsidian](https://github.com/dbarenholz/halcyon-obsidian)

## Disclaimer

Anthropic's Claude did help write the build scripts.
