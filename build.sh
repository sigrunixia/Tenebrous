#!/usr/bin/env bash
# Build and deploy the Tenebrous themes. Paths come from .env (see .env.example).
# Flags stack, and steps run in this order.
#
#   --obsidian-theme        theme.css and the snippets
#   --obsidian-publish-css  publish.css
#   --obsidian-publish-js   publish.js
#   --obsidian-push         push publish.css and/or publish.js live, whichever
#                           were built this run (both if none were)
#   --site                  tenebrousdragon.com, built with ./build.sh in SITE_REPO.
#                           It builds public/ only; run wrangler deploy there to go live
#   --zed                   Zed theme
#   --ghostty               Ghostty theme
#   --fish                  fish theme
#   --starship              Starship config
#   --fzf                   fzf colours, deployed to ~/.config/tenebrous/fzf-colors
#   --all                   everything above except --site and --obsidian-push
#   --build-only            build, deploy and push nothing
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$HERE/.env" ]; then
  set -a
  . "$HERE/.env"
  set +a
fi

need() {
  if [ -z "${!1:-}" ]; then
    echo "$1 is not set. Copy .env.example to .env and fill it in." >&2
    exit 1
  fi
}

THEME=0
PUB_CSS=0
PUB_JS=0
PUSH=0
SITE=0
ZED=0
GHOSTTY=0
FISH=0
STARSHIP=0
FZF=0
DEPLOY=1
for arg in "$@"; do
  case "$arg" in
    --obsidian-theme)       THEME=1 ;;
    --obsidian-publish-css) PUB_CSS=1 ;;
    --obsidian-publish-js)  PUB_JS=1 ;;
    --obsidian-push)        PUSH=1 ;;
    --site)                 SITE=1 ;;
    --zed)                  ZED=1 ;;
    --ghostty)              GHOSTTY=1 ;;
    --fish)                 FISH=1 ;;
    --starship)             STARSHIP=1 ;;
    --fzf)                  FZF=1 ;;
    --all)                  THEME=1; PUB_CSS=1; PUB_JS=1; ZED=1; GHOSTTY=1; FISH=1; STARSHIP=1; FZF=1 ;;
    --build-only)           DEPLOY=0 ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: build.sh [--obsidian-theme] [--obsidian-publish-css] [--obsidian-publish-js] [--obsidian-push] [--site] [--zed] [--ghostty] [--fish] [--starship] [--fzf] [--all] [--build-only]" >&2
      exit 2 ;;
  esac
done

if [ $((THEME + PUB_CSS + PUB_JS + PUSH + SITE + ZED + GHOSTTY + FISH + STARSHIP + FZF)) = 0 ]; then
  echo "Nothing to do. Pass at least one flag, or --all." >&2
  exit 2
fi

if [ "$PUSH" = 1 ] && [ "$DEPLOY" = 0 ]; then
  echo "--obsidian-push cannot be combined with --build-only." >&2
  exit 2
fi

sass_build() {
  sass --no-source-map "$OBSIDIAN_REPO/src/$1" "$OBSIDIAN_REPO/$2"
  echo "Built $2"
}

deploy_check() {
  need VAULT
  if [ ! -d "$VAULT/.obsidian" ]; then
    echo "No vault at $VAULT." >&2
    exit 1
  fi
}

if [ $((THEME + PUB_CSS + SITE + ZED + GHOSTTY + FISH + STARSHIP + FZF)) -gt 0 ]; then
  if [ $((THEME + PUB_CSS + SITE)) -gt 0 ]; then need OBSIDIAN_REPO; fi
  if [ "$SITE" = 1 ]; then need SITE_REPO; fi
  if [ "$ZED" = 1 ]; then need ZED_REPO; fi
  if [ "$GHOSTTY" = 1 ]; then need GHOSTTY_REPO; fi
  if [ "$FISH" = 1 ]; then need FISH_REPO; fi
  if [ "$STARSHIP" = 1 ]; then need STARSHIP_REPO; fi
  python3 "$HERE/build-palette.py"
  echo "Generated palette files from palette.json"
fi

if [ "$THEME" = 1 ]; then
  sass_build main.scss theme.css
  sass_build snippets/main-landing-snippet.scss snippets/landing-preview.css
  sass_build snippets/main-contact-snippet.scss snippets/contact-preview.css
  sass_build snippets/main-trips-snippet.scss snippets/trips-preview.css
  if [ "$DEPLOY" = 1 ]; then
    deploy_check
    cp "$OBSIDIAN_REPO/theme.css"                    "$VAULT/.obsidian/themes/Tenebrous/theme.css"
    cp "$OBSIDIAN_REPO/snippets/landing-preview.css" "$VAULT/.obsidian/snippets/landing-preview.css"
    cp "$OBSIDIAN_REPO/snippets/contact-preview.css" "$VAULT/.obsidian/snippets/contact-preview.css"
    cp "$OBSIDIAN_REPO/snippets/trips-preview.css"   "$VAULT/.obsidian/snippets/trips-preview.css"
    echo "Deployed theme and snippets to $VAULT"
  fi
fi

if [ "$PUB_CSS" = 1 ]; then
  need OBSIDIAN_REPO
  sass_build main-publish.scss publish.css
  if [ "$DEPLOY" = 1 ]; then
    deploy_check
    cp "$OBSIDIAN_REPO/publish.css" "$VAULT/publish.css"
    echo "Deployed publish.css to $VAULT"
  fi
fi

if [ "$PUB_JS" = 1 ]; then
  need OBSIDIAN_REPO
  need VAULT
  # build-index.js bakes the vault data into src/scripts/baked-data.ts, then
  # runs the repo's build-publish.sh (tsc and esbuild) to write publish.js.
  # Cover images only go to the live site when pushing.
  COVER_FLAG=""
  if [ "$PUSH" = 1 ]; then COVER_FLAG="--publish-covers"; fi
  node "$OBSIDIAN_REPO/build-index.js" "$VAULT" $COVER_FLAG >/dev/null
  echo "Built publish.js"
  if [ "$DEPLOY" = 1 ]; then
    deploy_check
    cp "$OBSIDIAN_REPO/publish.js" "$VAULT/publish.js"
    echo "Deployed publish.js to $VAULT"
  fi
fi

if [ "$SITE" = 1 ]; then
  # The site compiles the shared partials from the Obsidian repo, so build it
  # after the palette above. Deploying is a separate step (wrangler deploy).
  (cd "$SITE_REPO" && THEME_DIR="$OBSIDIAN_REPO" ./build.sh)
  echo "Built $SITE_REPO/public"
fi

if [ "$PUSH" = 1 ]; then
  need VAULT_NAME
  files=()
  [ "$PUB_CSS" = 1 ] && files+=(publish.css)
  [ "$PUB_JS" = 1 ] && files+=(publish.js)
  [ ${#files[@]} -gt 0 ] || files=(publish.css publish.js)
  for f in "${files[@]}"; do
    obsidian publish:add vault="$VAULT_NAME" file="$f"
  done
fi

if [ "$ZED" = 1 ]; then
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$ZED_REPO/themes/tenebrous.json"
  echo "Checked $ZED_REPO/themes/tenebrous.json"
  if [ "$DEPLOY" = 1 ]; then
    need ZED_THEMES
    mkdir -p "$ZED_THEMES"
    cp "$ZED_REPO/themes/tenebrous.json" "$ZED_THEMES/tenebrous.json"
    echo "Deployed to $ZED_THEMES"
  fi
fi

if [ "$GHOSTTY" = 1 ]; then
  echo "Built $GHOSTTY_REPO/Tenebrous"
  if [ "$DEPLOY" = 1 ]; then
    dir="${GHOSTTY_THEMES:-$HOME/.config/ghostty/themes}"
    mkdir -p "$dir"
    cp "$GHOSTTY_REPO/Tenebrous" "$dir/Tenebrous"
    echo "Deployed to $dir"
  fi
fi

if [ "$FISH" = 1 ]; then
  echo "Built $FISH_REPO/Tenebrous.theme"
  if [ "$DEPLOY" = 1 ]; then
    dir="${FISH_THEMES:-$HOME/.config/fish/themes}"
    mkdir -p "$dir"
    cp "$FISH_REPO/Tenebrous.theme" "$dir/Tenebrous.theme"
    echo "Deployed to $dir"
  fi
fi

if [ "$STARSHIP" = 1 ]; then
  echo "Built $STARSHIP_REPO/starship.toml"
  if [ "$DEPLOY" = 1 ]; then
    dest="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
    cp "$STARSHIP_REPO/starship.toml" "$dest"
    echo "Deployed to $dest"
  fi
fi

if [ "$FZF" = 1 ]; then
  echo "Built $HERE/fzf-colors"
  if [ "$DEPLOY" = 1 ]; then
    dir="${FZF_COLORS_DIR:-$HOME/.config/tenebrous}"
    mkdir -p "$dir"
    cp "$HERE/fzf-colors" "$dir/fzf-colors"
    echo "Deployed to $dir"
  fi
fi
