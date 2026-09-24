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

./scripts/feeds install -a

cp "$TOP/configs/seed.config" .config
make defconfig

make download -j8
make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)" V=s

mkdir -p "$TOP/output"
rm -rf "$TOP/output"/*
cp -a bin/targets/rockchip/armv8 "$TOP/output/"

echo "Build finished. Firmware is under: $TOP/output/"
