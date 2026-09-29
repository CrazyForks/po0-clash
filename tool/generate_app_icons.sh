#!/usr/bin/env bash
# Renders every launcher, window and store icon from assets_source/images/icon.
# Needs rsvg-convert (librsvg) and cwebp; tray icons come from
# tool/generate_status_icons.dart, which this script runs last.
set -euo pipefail
cd "$(dirname "$0")/.."

src=assets_source/images/icon
res=android/app/src/main/res
mac=macos/Runner/Assets.xcassets/AppIcon.appiconset
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cp "$src/app_icon.svg" "$tmp/app_icon.svg"
wrap() {
  local name=$1 clip=$2
  cat > "$tmp/$name.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1024" height="1024" viewBox="0 0 1024 1024">
  <defs><clipPath id="c">$clip</clipPath></defs>
  <g clip-path="url(#c)"><image xlink:href="app_icon.svg" width="1024" height="1024"/></g>
</svg>
SVG
}
wrap rounded '<rect width="1024" height="1024" rx="230" ry="230"/>'
wrap round '<circle cx="512" cy="512" r="512"/>'

render() { rsvg-convert -w "$2" -h "$3" -o "$4" "$1"; }
webp() {
  render "$1" "$2" "$2" "$tmp/out.png"
  cwebp -quiet -lossless "$tmp/out.png" -o "$3"
}

render "$tmp/rounded.svg" 512 512 assets/images/icon.png
render "$src/app_icon.svg" 512 512 android/app/src/main/ic_launcher-playstore.png

for size in 16 32 64 128 256 512 1024; do
  render "$src/app_icon_macos.svg" "$size" "$size" "$mac/app_icon_$size.png"
done

declare -A scale=([mdpi]=1 [hdpi]=1.5 [xhdpi]=2 [xxhdpi]=3 [xxxhdpi]=4)
for density in "${!scale[@]}"; do
  s=${scale[$density]}
  layer=$(python3 -c "print(int(108 * $s))")
  legacy=$(python3 -c "print(int(48 * $s))")
  mkdir -p "$res/mipmap-$density" "$res/mipmap-television-$density"
  render "$src/launcher_foreground.svg" "$layer" "$layer" "$res/mipmap-$density/ic_launcher_foreground.png"
  render "$src/launcher_background.svg" "$layer" "$layer" "$res/mipmap-$density/ic_launcher_background.png"
  webp "$tmp/rounded.svg" "$legacy" "$res/mipmap-$density/ic_launcher.webp"
  webp "$tmp/round.svg" "$legacy" "$res/mipmap-$density/ic_launcher_round.webp"
  webp "$tmp/rounded.svg" "$legacy" "$res/mipmap-television-$density/ic_launcher.webp"
done
render "$src/banner.svg" 320 180 "$res/mipmap-xhdpi/ic_banner.png"

dart run tool/generate_status_icons.dart
cp windows/runner/resources/app_icon.ico assets/images/icon.ico
