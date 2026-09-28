po0-clash v1.0.0：第一个独立发布的版本，基于上游 FlClash v0.8.98。

## 本次更新

- 改名为 po0-clash，成为独立应用：应用 ID、安装标识、进程名、服务名和数据目录都与官方 FlClash 不同
- 可以与官方 FlClash 同时安装、同时运行，Windows 安装包不再覆盖官方版，Android 无需先卸载官方版
- 版本号独立，从 1.0.0 开始，不再使用 0.8.98-po0.N 形式
- Android APK 改由 GitHub Actions 与桌面端一起构建发布
- 移除 Firebase / Crashlytics，应用不再上报任何崩溃或统计数据

## 从旧版 FlClash-po0 迁移

- po0-clash 不会覆盖或升级旧的 FlClash-po0（0.8.98-po0.1～po0.6），两者作为不同应用共存
- 在旧版「备份与恢复」中导出本地备份文件，再在 po0-clash 中导入即可带回订阅、设置和 po0 token；也可以直接重新填写 token
- 确认新版正常后请自行卸载旧版，旧版不会再收到更新

## 功能

- po0 防火墙自动加白：主导航中的 po0 页面，填入 token 后只要应用打开就按刷新间隔检查白名单（只读查询，不占坑位），本机出口不在名单时立即加白，无论代理是否开启
- token 列表管理：逐个添加、编辑、删除，可填备注名和固定槽位；刷新间隔 1～3600 秒，默认 1 秒
- Android 只在亮屏时检查，熄屏自动暂停，亮屏立即恢复
- 加白请求强制直连，并自动为 124.221.69.228 添加直连规则、排除出 TUN / VPN 路由
- Windows / macOS 使用 HeroUI 风格界面：分组设置卡片、页面淡入、侧边栏滑动选中、卡片悬停反馈

## 安装

- Windows：po0-clash-1.0.0-windows-amd64-setup.exe（安装包）或 .zip（免安装）
- macOS：curl -fsSL https://raw.githubusercontent.com/yuuuki-creation/po0-clash/main/scripts/install-macos.sh | bash
- Android：po0-clash-1.0.0-android-arm64-v8a.apk（主流机型），可与官方 FlClash 共存

## 已知限制

- Android 首次开启自动加白后需重启一次 VPN，直连路由才会生效
- Android 从最近任务划掉 po0-clash 后停止检查，重新打开应用即恢复
- 同时在用的网段超过白名单容量（5 减去固定槽位数）时，各设备会互相挤占
- 与其他代理客户端同时开启系统代理或 TUN 会互相抢占，请只在一个应用里开启
- macOS 版本未经 Apple 公证，安装脚本会移除隔离属性
- 旧版 FlClash-po0 的检查更新即使提示了本版本，安装后也是作为新应用共存，不会替换旧版
