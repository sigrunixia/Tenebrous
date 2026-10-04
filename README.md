# Tenebrous

Custom Color Scheme I created based off the dragon that I am/play.

![The Tenebrous palette](palette.svg)

## Themes

- [Tenebrous Obsidian](https://github.com/sigrunixia/Tenebrous-Obsidian), the theme for Obsidian
- [Tenebrous Zed](https://github.com/sigrunixia/Tenebrous-Zed), the theme for Zed

## Colors

| Name | Hex |
|---|---|
| bg-dark2 | `#0d0e10` |
| bg | `#14161b` |
| bg-highlight | `#242838` |
| bg-highlight-dk | `#1d202b` |
| fg | `#a6accd` |
| fg-dark | `#898fb3` |
| comment | `#6d7397` |
| blue0 | `#7aa6e6` |
| amber | `#f0b04a` |
| amber0 | `#e8a955` |
| magenta | `#a894e8` |
| teal | `#5fb8c8` |
| green | `#5de4c7` |
| green0 | `#5fb3a1` |
| red | `#e0604a` |
| red1 | `#f07a62` |
| orange | `#f5a04a` |
| cyan | `#89ddff` |
| lime | `#a8d86e` |
| rose | `#d0679d` |
| crimson | `#dc6074` |
| pink | `#f087bd` |
| yellow | `#fffac2` |
| silver | `#e2e7f2` |
| unknown | `#ffffff` |

Zed also uses a few extra shades for its accent and dim terminal colors.

| Name | Hex |
|---|---|
| accent | `#3980c6` |
| red-dim | `#a8473a` |
| blue-dim | `#5d7fb0` |
| magenta-dim | `#8070b0` |
| cyan-dim | `#4a8f9c` |

## Building

Every color lives in `palette.json`. Run `build.sh` and it writes the Obsidian palette file, the Zed theme and `palette.svg` from it, so a color only ever gets changed in one place.

```
./build.sh --obsidian-theme        # theme.css and snippets
./build.sh --obsidian-publish-css  # publish.css
./build.sh --obsidian-publish-js   # publish.js
./build.sh --obsidian-push         # push publish.css and/or publish.js live
./build.sh --zed                   # Zed theme
./build.sh --all                   # everything except the push
./build.sh --build-only            # build without deploying
```

Flags stack, so `./build.sh --obsidian-publish-css --obsidian-push` builds publish.css and pushes just that.

Copy `.env.example` to `.env` and point it at your repos and vault. The script reads it every run. Change the Zed template, not the Zed theme it spits out, because the next build writes over it.

## Disclaimer

Claude did help write the build script.
