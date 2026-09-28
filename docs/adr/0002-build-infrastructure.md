# 0002. 构建基础设施：VPS + GitHub Actions

- 状态：已采纳；Android 构建与签名部分已取代（见 [0006](0006-standalone-app-identity.md)）
- 日期：2026-09-27

## 背景

交付目标包括 Windows 安装包、macOS 安装、Android APK。约束：

- 指定的构建 VPS 为 Debian 13 x86_64。
- Flutter 桌面端不支持交叉编译：Windows 产物只能在 Windows 上构建，macOS 产物只能在 macOS 上构建。
- 开发机（Windows）未开启开发者模式，`flutter pub get` 无法创建插件符号链接；开启它属于修改系统设置。
- 仓库为私有，GitHub Actions 按分钟计费（Windows ×2、macOS ×10）。

## 决定

- VPS 负责：代码生成、analyze、test、覆盖率门槛，以及 Android APK 的构建与签名。
- GitHub Actions 只负责 Windows 与 macOS 的发版构建（标签或手动触发），产物直接挂到 Release。
- 上游的全量 CI（`build.yaml`）改为仅手动触发，避免每次推送消耗分钟数。
- VPS 通过只读 deploy key 拉取代码；签名密钥只存在于 VPS 的 `/root/flclash-po0-secrets/`，不入库。

## 后果

- 每次发版的 Actions 消耗约：Windows 1 个任务 + macOS 2 个任务。
- 若 Actions 配额不足，Windows 产物可在开启开发者模式（或管理员权限）的 Windows 机器上用 `dart setup.dart windows --env stable` 本地构建。
- VPS 是 Android 签名密钥的唯一持有者，需要定期备份 `/root/flclash-po0-secrets/`。
