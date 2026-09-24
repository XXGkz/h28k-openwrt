#!/bin/sh
set -eu

# PassWall 2 upstream
rm -rf package/passwall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2.git package/passwall2

# MosDNS v5 and its geodata package.
# The MosDNS project documents that OpenWrt 25.12 builds use a newer Go toolchain.
rm -rf package/mosdns package/v2ray-geodata
git clone --depth=1 --branch v5 https://github.com/sbwml/luci-app-mosdns.git package/mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata.git package/v2ray-geodata

# MosDNS v5 currently expects a newer Go toolchain than some 25.12 feed snapshots.
rm -rf feeds/packages/lang/golang
git clone --depth=1 --branch 26.x https://github.com/sbwml/packages_lang_golang.git feeds/packages/lang/golang

# Avoid duplicate geodata package from the official package feed.
rm -rf package/feeds/packages/v2ray-geodata feeds/packages/net/v2ray-geodata 2>/dev/null || true
