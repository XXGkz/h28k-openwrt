#!/bin/sh
set -eu

TOP="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OPENWRT="$TOP/work/openwrt"
TARGET="$OPENWRT/bin/targets/rockchip/armv8"
MANIFEST="$TARGET"/*.manifest

test -s "$TOP/build.log"
test -s "$TARGET"/*hinlink_h28k*squashfs-sysupgrade.img.gz

# Stop on actionable dependency/package warnings, while allowing ordinary compiler warnings.
if grep -Ein 'WARNING:.*(does not exist|not found|missing|dependency|unmet)|WARNING:.*(skipping|failed)|Collected errors:' "$TOP/build.log"; then
  echo "ERROR: actionable package/dependency warnings were found in build.log"
  exit 1
fi

for pkg in luci-app-passwall2 luci-app-mosdns luci-i18n-passwall2-zh-cn luci-i18n-mosdns-zh-cn   mosdns ucode tcping geoview xray-core sing-box v2ray-geoip v2ray-geosite
do
  grep -q "^Package: $pkg$" $MANIFEST
done

echo "Post-build validation: OK"
