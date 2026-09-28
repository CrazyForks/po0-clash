po0-clash v5.0.0：迁到新仓库后的第一个版本，基于上游 FlClash v0.8.98。

## 本次更新

- 版本号从 5.0.0 起算
- 项目迁到 yuuuki-creation/po0-clash，检查更新和 macOS 安装脚本都指向新仓库
- 应用 ID 改为 io.github.yuuukicreation.po0clash，Android 使用新的签名证书
- 可与官方 FlClash 同时安装、同时运行，互不覆盖
- 不包含 Firebase / Crashlytics，应用不上报任何崩溃或统计数据

## 从旧版迁移（先读再装）

- 旧版 po0-clash 1.0.0 和 FlClash-po0（0.8.98-po0.N）都收不到本版本的更新提示，请手动下载安装
- 应用 ID 和数据目录都已更换，旧版的订阅、设置和 po0 token 不会自动带过来
- 安装前先在旧版「备份与恢复」导出本地备份，装好后在本版本导入；也可以直接重新填写 token
- Windows / macOS：本版本会替换已安装的 po0-clash 1.0.0 程序，所以务必先导出备份；FlClash-po0 与本版本共存
- Android：签名证书已更换，本版本作为新应用安装，不会覆盖旧版；确认正常后请自行卸载旧版

## 功能

- po0 防火墙自动加白：主导航中的 po0 页面，填入 token 后只要应用打开就按刷新间隔检查白名单（只读查询，不占坑位），本机出口不在名单时立即加白，无论代理是否开启
- token 列表管理：逐个添加、编辑、删除，可填备注名和固定槽位；刷新间隔 1～3600 秒，默认 1 秒
- Android 只在亮屏时检查，熄屏自动暂停，亮屏立即恢复
- 加白请求强制直连，并自动为 124.221.69.228 添加直连规则、排除出 TUN / VPN 路由
- Windows / macOS 使用 HeroUI 风格界面：分组设置卡片、页面淡入、侧边栏滑动选中、卡片悬停反馈

## 安装

- Windows：po0-clash-5.0.0-windows-amd64-setup.exe（安装包）或 .zip（免安装）
- macOS：curl -fsSL https://raw.githubusercontent.com/yuuuki-creation/po0-clash/main/scripts/install-macos.sh | bash
- Android：po0-clash-5.0.0-android-arm64-v8a.apk（主流机型），可与官方 FlClash 共存

## 已知限制

- Android 首次开启自动加白后需重启一次 VPN，直连路由才会生效
- Android 从最近任务划掉 po0-clash 后停止检查，重新打开应用即恢复
- 同时在用的网段超过白名单容量（5 减去固定槽位数）时，各设备会互相挤占
- 与其他代理客户端同时开启系统代理或 TUN 会互相抢占，请只在一个应用里开启
- macOS 版本未经 Apple 公证，安装脚本会移除隔离属性
