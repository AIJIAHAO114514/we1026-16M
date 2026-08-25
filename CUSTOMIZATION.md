# OpenWrt 定制固件：ZBT-WE1026（16M）山区 4G 网关

基于 OpenWrt 25.12.2（ramips/mt7620），为 **ZBT-WE1026**（非 5G、双网口、16M 闪存）定制的 4G 摄像头网关固件。本文件说明相对上游源码树的全部定制内容。

## 功能

- EC20 4G 拨号：QMI 模式，电信 ctnet（luci-proto-qmi + uqmi）
- frpc 隧道转发：8 条隧道，`login_fail_exit=false` 防崩溃循环
- Modem Band 图形锁频：modemband + luci-app-modemband（EC20 支持）
- EC20 SRLTE 一键修复：`fix-ec20-srlte.sh` + LuCI 自定义命令按钮（电信 CDMA 退网后搜不到网时使用）
- watchcat 断网自愈（预置配置，默认不启用服务）
- 无 WiFi 精简、软件流卸载、中文 LuCI、USTC 软件源

## 目录说明

| 路径 | 内容 |
|---|---|
| `target/linux/ramips/dts/mt7620a_zbtlink_zbt-we1026-16m.dts` | 新设备 DTS（we1026-h 基底 + 16M 分区） |
| `target/linux/ramips/image/mt7620.mk` | 设备定义（4G 包、删 WiFi 包） |
| `target/linux/ramips/mt7620/base-files/etc/board.d/` | 端口（`3:lan 4:wan`）与 LED 配置 |
| `package/modemband/` | 第三方：频段管理核心（obsy） |
| `package/luci-app-modemband/` | 第三方：频段管理 LuCI 界面（4IceG） |
| `files/` | 现场配置（**含密码等敏感信息，已通过 .gitignore 排除，需自行准备**） |

## 构建

1. 下载 OpenWrt 25.12.2 源码树，将本仓库文件覆盖/合并进去
2. 更新 feeds（国内网络可在 `feeds.conf.default` 用 `gh-proxy.com` 前缀加速）
3. 编译 frp 需要配置 Go 模块代理（国内必需），手动改两个文件：
   - `feeds/packages/lang/golang/golang-values.mk` 添加：
     `GO_BUILD_GOPROXY:=$(or $(call qstrip,$(CONFIG_GOLANG_GOPROXY)),https://goproxy.cn,direct)`
   - `feeds/packages/lang/golang/golang-package.mk` 的 `GO_PKG_BUILD_VARS` 添加：
     `GOPROXY="$(GO_BUILD_GOPROXY)"`
4. 准备 `files/` 目录（frpc 配置、uci-defaults 现场脚本，内容自定）
5. `make defconfig && make -j$(nproc)`
6. 固件产物：
   `bin/targets/ramips/mt7620/openwrt-ramips-mt7620-zbtlink_zbt-we1026-16m-squashfs-sysupgrade.bin`

## 第三方包来源

- [obsy/modemband](https://github.com/obsy/modemband)
- [4IceG/luci-app-modemband](https://github.com/4IceG/luci-app-modemband)
- sms-tool、watchcat、luci-app-commands、frpc 等均来自官方 feeds

## 隐私声明

`files/` 目录（frpc token、root 密码、APN 等现场配置）通过 `.gitignore` 的 `/files` 规则排除，不会出现在本仓库中。使用本仓库前请自行准备该目录。
