#!/bin/sh
set -eu

OPENWRT_REF="${OPENWRT_REF:-v25.12.5}"
TOP="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
WORK="${TOP}/work"

rm -rf "$WORK"
mkdir -p "$WORK"

git clone --depth=1 --branch "$OPENWRT_REF" https://github.com/openwrt/openwrt.git "$WORK/openwrt"
cd "$WORK/openwrt"

cp "$TOP/feeds.conf.default" feeds.conf.default
./scripts/feeds update -a

sh "$TOP/scripts/prepare-feeds.sh"

# Install only package metadata from the official feeds. Local package trees
# (PassWall2/MosDNS/PassWall dependencies) are picked up directly by OpenWrt.
./scripts/feeds install -a

cp "$TOP/configs/seed.config" .config
make defconfig

# Some LuCI translation packages are hidden Kconfig symbols. Explicitly force
# the requested Chinese translations after defconfig so they cannot be pruned
# as optional/hidden packages.
for pkg in \
  luci-i18n-base-zh-cn \
  luci-i18n-passwall2-zh-cn \
  luci-i18n-mosdns-zh-cn \
  luci-i18n-statistics-zh-cn
do
  sed -i "/^# CONFIG_PACKAGE_\${pkg} is not set$/d; /^CONFIG_PACKAGE_\${pkg}=/d" .config
  printf 'CONFIG_PACKAGE_%s=y\n' "$pkg" >> .config
done

# Fail early if the requested target or required Chinese translations were
# silently dropped by Kconfig.
grep -q '^CONFIG_TARGET_rockchip_armv8_DEVICE_hinlink_h28k=y$' .config
for pkg in \
  luci-i18n-base-zh-cn \
  luci-i18n-passwall2-zh-cn \
  luci-i18n-mosdns-zh-cn \
  luci-i18n-statistics-zh-cn
do
  grep -q "^CONFIG_PACKAGE_\${pkg}=y$" .config
done

echo "Selected target:"
grep '^CONFIG_TARGET_rockchip_armv8_DEVICE_hinlink_h28k=' .config

echo "Selected proxy/DNS packages:"
grep -E '^CONFIG_PACKAGE_(luci-app-passwall2|tcping|geoview|v2ray-geoip|v2ray-geosite|xray-core|sing-box|chinadns-ng|mosdns|luci-app-mosdns)=' .config || true

make download -j8
make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)" V=s

mkdir -p "$TOP/output"
rm -rf "$TOP/output"/*
cp -a bin/targets/rockchip/armv8 "$TOP/output/"

echo "Build finished. Firmware is under: $TOP/output/"
