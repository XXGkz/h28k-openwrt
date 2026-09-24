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

# Fail early if the requested H28K target was silently dropped by defconfig.
grep -q '^CONFIG_TARGET_rockchip_armv8_DEVICE_hinlink_h28k=y$' .config

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
