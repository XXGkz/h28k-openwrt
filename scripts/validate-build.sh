#!/bin/sh
set -eu

TOP="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OPENWRT="$TOP/work/openwrt"
TARGET="$OPENWRT/bin/targets/rockchip/armv8"
MANIFEST="$TARGET"/*.manifest

test -s "$TOP/build.log"
IMAGE="$(find "$TARGET" -maxdepth 1 -type f -name '*hinlink_h28k*squashfs-sysupgrade.img.gz' -print -quit)"
test -n "$IMAGE"
test -s "$IMAGE"

if grep -Ein 'Collected errors:|ERROR:.*(luci-app-passwall2|luci-app-mosdns|mosdns|xray-core|sing-box|tcping|geoview|v2ray-geodata)' "$TOP/build.log"; then
  echo "ERROR: actionable package errors were found in build.log"
  exit 1
fi

# OpenWrt 25.12 uses apk manifests: package-name - version.
required_packages="
luci
luci-i18n-base-zh-cn
luci-app-passwall2
luci-i18n-passwall2-zh-cn
luci-app-mosdns
luci-i18n-mosdns-zh-cn
luci-app-statistics
luci-i18n-statistics-zh-cn
mosdns
ucode
tcping
geoview
xray-core
sing-box
v2ray-geoip
v2ray-geosite
chinadns-ng
"

missing=0
for pkg in $required_packages; do
  if ! grep -Eq "^${pkg} - " $MANIFEST; then
    echo "ERROR: required package missing from final manifest: $pkg"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

grep -Rqs '"supported_devices":["hinlink,h28k"]' "$TARGET"/*.json"
grep -Rqs '"target":"rockchip/armv8"' "$TARGET"/*.json"
grep -Rqs '"board":"hinlink_h28k"' "$TARGET"/*.json"

echo "Post-build validation: OK"
