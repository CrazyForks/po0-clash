# 磨砂玻璃界面

Android、Windows、macOS 共用一套磨砂玻璃界面，决策记录见 [ADR 0009](../adr/0009-frosted-glass-ui.md)。

## 设计令牌

- `lib/common/glass.dart`：`GlassStyle`（主题扩展）由配色方案生成面板、磁贴、浮层、菜单的填充色，高光描边、
  阴影、选中色和极光调色板（基色渐变 + 4 个光斑，色相取自主题主色）；`GlassTone` 提供成功 / 警告 / 危险等语义色。
- `lib/common/app_theme.dart`：`ColorScheme.toGlass` 把 `surfaceContainer*` 换成白色薄纱，Material 组件自动呈现玻璃感；
  `surface` 保持不透明，作为整页的底色。
- `lib/common/shape.dart`：圆角档位 8 / 12 / 18 / 24 / 28 / 32 / full，`AppShape` 为连续曲率圆角。

## 组件（`lib/widgets/glass.dart`）

| 组件 | 用途 |
|---|---|
| `AuroraBackdrop` / `AppBackdrop` | 全窗口极光背景，切换空间时光斑缓慢漂移（减少动画时直接到位） |
| `AuroraFloor` | 盖满窗口的推入页面自带同一层极光背景 |
| `GlassSurface` | 玻璃面：薄纱填充、顶部光泽、渐变描边、只画在外侧的阴影；`chrome` 类型才做背景模糊 |
| `GlassButton` | 可点击的玻璃面，悬停 / 按下 / 焦点从内部提亮 |
| `GlassSegmented` | 玻璃轨道 + 滑动的高亮胶囊（出站模式、活动页） |
| `GlassIconBadge`、`GlassPill`、`GlassSectionLabel` | 图标徽章、状态胶囊、分组标题 |

## 操作结构（`lib/pages/home.dart`、`lib/pages/shell.dart`）

| 窗口宽度 | 布局 |
|---|---|
| < 600 dp | 页面铺满，底部悬浮玻璃底栏：主页、代理、配置、po0、设置；「活动」从设置或主页网速卡片进入 |
| 600～839 dp | 左侧玻璃侧栏 + 玻璃工作区，包含主页和活动 |
| ≥ 840 dp | 左侧常驻控制栏（光球、出站模式、各空间实时状态、网速与出口 IP）+ 工作区；主页内容已在控制栏中 |

- 控制中心：`lib/views/control/`（光球 `ConnectOrb`、磁贴 `tiles.dart`、内核状态 `CoreStatusButton`）。
- 活动：`lib/views/activity.dart`，通过 `ScaffoldTitleSlot` 把分段切换放在标题位置。
- 设置：`lib/views/tools.dart`，按外观、网络与内核、应用、其他分组的磁贴。

## 图标

源文件在 `assets_source/images/icon/`（应用图标、macOS 图标、Android 自适应图标前景 / 背景、TV 横幅、托盘图标），
运行 `bash tool/generate_app_icons.sh` 生成全部尺寸，需要 `rsvg-convert` 与 `cwebp`。
