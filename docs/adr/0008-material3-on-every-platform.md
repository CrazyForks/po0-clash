# 0008. 三端统一使用 Material 3

- 状态：已采纳
- 日期：2026-09-29
- 取代：[0003](0003-heroui-desktop-theme.md)

## 背景

[0003](0003-heroui-desktop-theme.md) 让 Windows、macOS 使用 HeroUI 风格的主题与侧边栏，Android 保持 Material。
两套视觉语言带来了几个问题：

- 桌面端的动态取色、配色方案变体、纯黑模式都不生效。
- 组件和动效各写一份，维护成本翻倍。
- 大量自绘组件与任何一套规范都不符：仿 Cupertino 的分段控件、自定义弹出菜单、手绘标签、带回弹的动画曲线、
  编辑模式下的抖动。

维护者决定三端统一遵循 [Android 设计指南](https://developer.android.com/design/ui)，也就是 Material 3。

## 决定

- **主题**：三端共用 `buildAppTheme`（`lib/common/app_theme.dart`），即种子配色的 Material 3 `ThemeData`。
  模态弹窗与面板背后使用 32% 的 scrim（`ColorScheme.modalScrim`），不再模糊背景。
  默认配色仿照 Android 设计网站：藏青 `#073042` 负责主要操作，Android 绿 `#3DDC84` 负责选中态，变体默认 `fidelity`。
- **形状**：`AppCorner` / `AppRadius` / `AppShape` 使用 Material 3 的圆角档位，均为普通圆角矩形：
  - extraSmall 4、small 8、medium 12、large 16、largeIncreased 20、extraLarge 28、full；
  - 组件沿用 Material 3 默认圆角：卡片 12，菜单与输入框 4，对话框与底部面板 28，FAB 16。
- **导航**：按窗口宽度分级。
  - 小于 600 dp：底部导航栏；
  - 600～839 dp：收起的导航侧栏；
  - 840 dp 及以上：导航侧栏，顶部的菜单按钮可将其展开。
- **转场**：
  - 主页面切换使用 fade through，共 300 ms：前 35% 旧页面淡出，后 65% 新页面淡入并从 92% 放大。
  - 推入页面：Android 使用预测性返回（`PredictiveBackPageTransitionsBuilder`，清单中开启
    `enableOnBackInvokedCallback`）；其他平台使用它的回退效果 FadeForwards。
- **组件**：`SegmentedButton`、`MenuAnchor`、`Chip` / `ActionChip` / `InputChip` 取代对应的自绘组件。
- **动效**：
  - 只使用 `Durations.*` 与 `Easing.*`；emphasized 曲线使用 `Curves.easeInOutCubicEmphasized`；不使用回弹曲线。
  - 进入用减速曲线，退出用加速曲线；反向曲线需要 `.flipped`，退出才会真正加速。
  - 遵守系统的「减少动画」设置。
  - 拖动时通过提升高度来表现，不做缩放。

## 后果

- 桌面端外观变化较大，但动态取色等主题设置重新生效。
- 删除了约五千行自绘主题、侧边栏与组件代码。
- 界面层与上游 FlClash 的差异扩大：移植上游界面改动时，需要按本 ADR 调整形状、动效与组件。
- `docs/features/images` 中的截图需要重新生成。
