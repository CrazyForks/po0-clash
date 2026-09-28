# 0003. 桌面端 HeroUI 风格主题

- 状态：已采纳
- 日期：2026-09-27

## 背景

目标要求 Windows 与 macOS 界面改为 HeroUI 风格，Android 不变。上游界面基于 Material 3（`material_ui`），
页面数量多，逐页重写既昂贵又会让后续合并上游变得困难。

## 决定

- 在主题层实现 HeroUI：`HeroTheme`（`ThemeExtension`）承载设计令牌，`heroColorScheme` 把 HeroUI 语义映射到
  Material 的颜色角色，`withHeroStyle` 覆盖各组件主题。现有页面无需修改即可获得 HeroUI 的配色、圆角、按钮与表单外观。
- 只有两处外观无法由主题表达，单独适配：导航侧边栏（新 `HeroSidebar`）与 `CommonCard`（环线 + 阴影 + 圆角）。
- 是否启用由 `application.dart` 按平台决定；组件只检查 `HeroTheme` 是否存在，不直接读平台。

## 后果

- 改动集中在 `lib/common/hero_theme.dart`、`lib/manager/hero_sidebar.dart` 与少量接线，合并上游时冲突面小。
- 主题设置页中的「配色方案变体」在 HeroUI 模式下不再生效（HeroUI 使用固定的中性色阶）；主题色仍可自选。
- 未打包 Inter 字体，拉丁文字使用系统字体（Windows: Segoe UI，macOS: SF Pro），中文使用系统中文字体。
