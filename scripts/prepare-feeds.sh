#!/bin/sh
set -eu

# PassWall2 itself.
rm -rf package/passwall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2.git package/passwall2

# PassWall2 runtime dependencies which are not present in the official 25.12 feeds.
# This repository provides tcping, geoview, xray-core, sing-box, v2ray-geoip,
# v2ray-geosite and related packages.
rm -rf package/passwall-packages
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/passwall-packages

# MosDNS v5 and its geodata package.
rm -rf package/mosdns package/v2ray-geodata
git clone --depth=1 --branch v5 https://github.com/sbwml/luci-app-mosdns.git package/mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata.git package/v2ray-geodata

# MosDNS v5 currently requires a newer Go toolchain than the stock 25.12 feed.
rm -rf feeds/packages/lang/golang
git clone --depth=1 --branch 26.x https://github.com/sbwml/packages_lang_golang.git feeds/packages/lang/golang

# Avoid duplicate geodata packages from the official packages feed.
rm -rf feeds/packages/net/v2ray-geodata package/feeds/packages/v2ray-geodata 2>/dev/null || true
