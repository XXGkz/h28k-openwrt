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

# Do not fail on unrelated compiler/feed warnings. The build itself already fails
# on hard compile errors; here we only reject explicit package collection errors.
if grep -Ein 'Collected errors:|ERROR:.*(luci-app-passwall2|luci-app-mosdns|mosdns|xray-core|sing-box|tcping|geoview|v2ray-geodata)' "$TOP/build.log"; then
  echo "ERROR: actionable package errors were found in build.log"
  exit 1
fi

for pkg in luci-app-passwall2 luci-app-mosdns luci-i18n-passwall2-zh-cn luci-i18n-mosdns-zh-cn \
  mosdns ucode tcping geoview xray-core sing-box v2ray-geoip v2ray-geosite
do
  grep -q "^Package: $pkg$" $MANIFEST
done

echo "Post-build validation: OK"
