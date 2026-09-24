#!/bin/sh
set -eu

# Pin third-party components to compatible release lines instead of tracking moving
# branches. This keeps PassWall2, Xray and the MosDNS Go toolchain aligned.
PASSWALL2_REF="26.8.27-1"
MOSDNS_REF="v5.3.4-r6"

rm -rf package/passwall2
git clone --depth=1 --branch "$PASSWALL2_REF" https://github.com/Openwrt-Passwall/openwrt-passwall2.git package/passwall2

rm -rf package/passwall-packages
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/passwall-packages

# Remove packages duplicated by PassWall's feed. Keeping both copies can produce
# dependency/version warnings during feeds install and defconfig.
rm -rf   feeds/packages/net/xray-core   feeds/packages/net/v2ray-geodata   feeds/packages/net/sing-box   feeds/packages/net/chinadns-ng   feeds/packages/net/dns2socks   feeds/packages/net/hysteria   feeds/packages/net/ipt2socks   feeds/packages/net/microsocks   feeds/packages/net/naiveproxy   feeds/packages/net/shadowsocks-rust   feeds/packages/net/shadowsocksr-libev   feeds/packages/net/simple-obfs   feeds/packages/net/tcping   feeds/packages/net/v2ray-plugin   feeds/packages/net/xray-plugin   feeds/packages/net/geoview   feeds/packages/net/shadow-tls   2>/dev/null || true

# MosDNS v5.3.4-r6 contains the current OpenWrt 25.12-compatible LuCI package
# (1.7.5) and its explicit ucode dependency, plus recent geodata/update fixes.
rm -rf package/mosdns package/v2ray-geodata
git clone --depth=1 --branch "$MOSDNS_REF" https://github.com/sbwml/luci-app-mosdns.git package/mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata.git package/v2ray-geodata

# MosDNS v5 requires the newer Go feed.
rm -rf feeds/packages/lang/golang
git clone --depth=1 --branch 26.x https://github.com/sbwml/packages_lang_golang.git feeds/packages/lang/golang
