po0-clash v5.1.0：三端统一 Material 3 界面，去掉固定槽位，默认每 5 秒检查一次。

## 本次更新

- Android、Windows、macOS 统一使用 Material 3 界面，遵循 Android 设计指南；Windows / macOS 不再使用 HeroUI 风格
- 默认配色改为 Android 藏青 + Android 绿；主题色、配色方案变体、纯黑模式与动态取色在桌面端同样生效
- 导航随窗口宽度切换：窄屏为底部导航栏，宽屏为左侧导航栏，默认展开，点顶部菜单按钮可收起
- 主页面切换改为淡出淡入，Android 子页面支持预测性返回手势，所有动画改用 Material 3 的时长与曲线
- 仪表盘出站模式、更多菜单和标签改用 Material 3 标准组件
- 新安装默认使用简体中文
- po0：去掉固定槽位，所有设备都走普通加白流程
- po0：刷新间隔默认改为 5 秒

## 升级说明

- 从 5.0.0 直接覆盖安装即可，设置全部保留
- 5.0.0 若仍是默认主题色，会自动换成新的默认配色；自己选过的颜色保持不变
- 已保存的刷新间隔不变，如需 5 秒请在 po0 页面修改
- 语言和侧边栏的新默认值只对新安装生效：已安装的可在「工具 → 语言」选择简体中文，点左侧栏顶部的菜单按钮展开
- 以前用固定槽位钉住的白名单记录仍留在 po0 服务端，不需要时请在 po0 面板删除

## 安装

- Windows：po0-clash-5.1.0-windows-amd64-setup.exe（安装包）或 .zip（免安装）
- macOS：curl -fsSL https://raw.githubusercontent.com/yuuuki-creation/po0-clash/main/scripts/install-macos.sh | bash
- Android：po0-clash-5.1.0-android-arm64-v8a.apk（主流机型），可与官方 FlClash 共存

## 已知限制

- Android 首次开启自动加白后需重启一次 VPN，直连路由才会生效
- Android 从最近任务划掉 po0-clash 后停止检查，重新打开应用即恢复
- 同时在用的网段超过白名单容量（5 条，服务端已有的固定记录也占名额）时，各设备会互相挤占
- 与其他代理客户端同时开启系统代理或 TUN 会互相抢占，请只在一个应用里开启
- macOS 版本未经 Apple 公证，安装脚本会移除隔离属性
