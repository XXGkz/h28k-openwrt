# HINLINK H28K OpenWrt 固件构建

面向 **HINLINK OPC-H28K / H28K (RK3528)** 的可复现 OpenWrt 25.12 构建配置。

## 默认内容

- Target: `rockchip/armv8`
- Device: `hinlink_h28k`
- LuCI 中文界面
- PassWall 2 + 中文语言包
- MosDNS v5 + 中文语言包
- Xray / Sing-box（由 PassWall 2 依赖配置）
- LuCI `luci-app-statistics`：CPU、负载、内存、接口、磁盘等 RRD 监控
- `luci-app-nlbwmon`：按主机统计流量
- `htop` / `tcpdump-mini` / `ethtool` / `curl` / `nano`
- 保守的默认服务：不自动开启 PassWall 2 / MosDNS，首次启动后手动配置，避免 DNS/代理配置错误导致失联
- GitHub Actions 自动编译并上传 `bin/targets/rockchip/armv8` 产物

## 为什么使用官方 OpenWrt 25.12

OpenWrt 25.12 已使用 `apk` 作为包管理器。该版本对 H28K 有官方设备定义，设备 DTS 为 `rk3528-hinlink-h28k`，U-Boot 设备名为 `hinlink-h28k-rk3528`。

本仓库默认固定到 `v25.12.5`，而不是滚动 snapshot，以减少长期运行中的 ABI / 依赖漂移。升级时只需要修改 `.github/workflows/build.yml` 中的 `OPENWRT_REF`，重新构建并进行完整 sysupgrade。

## 构建

最简单的方法：

1. Fork 本仓库。
2. 打开 `Actions`。
3. 运行 `Build OpenWrt H28K`。
4. 构建完成后在该 workflow 的 Artifacts 中下载 `openwrt-h28k-firmware`。
5. 解压后选择 `*-hinlink_h28k-squashfs-sysupgrade.img.gz` 进行升级。

首次刷写前请确认你当前设备确实是 HINLINK H28K / OPC-H28K，并保留原厂/当前固件及恢复方式。

## 维护策略

- 不建议在 25.12 上使用 `apk upgrade` 无差别升级全部软件包。
- 固件升级采用整套 sysupgrade，使内核、基础库、LuCI、PassWall 2、MosDNS 保持一致。
- PassWall 2 和 MosDNS 的上游版本通过 feeds/源码参与构建；GitHub Actions 会记录构建日志，便于以后复现。
- 本仓库不写入任何代理节点、订阅地址、密码或 DNS 私有配置。

## 首次启动建议

刷机后：

1. 先确认 LuCI 能正常访问。
2. 设置管理员密码。
3. 检查 `网络 -> 接口` 和 WAN/LAN。
4. 再配置 MosDNS。
5. 最后启用 PassWall 2。
6. 开启监控后观察 CPU、内存、负载、接口流量至少一段时间。

> 注意：PassWall 2 与 MosDNS 都会改变 DNS/流量路径。为了可恢复性，本仓库默认不在首次启动时强制开启它们。
