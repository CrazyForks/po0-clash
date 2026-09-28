# po0 防火墙自动加白

入口：主导航中的 **po0**（中文界面显示「po0 加白」），与仪表盘、代理、配置、工具同级——桌面端在侧边栏，手机端在底部导航栏。

## 页面

| 区块 | 内容 |
|---|---|
| 概览卡片 | 状态图标与标题（已加白 / 部分加白 / 未开启 / 未配置 token / 执行中）、当前出口、上次检查时间与检查间隔，右侧为「查询状态」「立即加白」 |
| 设置 | 自动加白开关、刷新间隔 |
| Token | token 列表：每行显示备注名（或 token 前 12 位）与固定槽位，可编辑、删除；右上角「添加 token」 |
| 白名单 | 每个 token 一张卡片：备注名、状态标签、固定槽位、结果说明、白名单占用进度条、白名单网段标签（当前出口高亮、固定槽位带图钉） |

![po0 页面（桌面浅色）](images/ui_po0_light.png)

## 用户可见行为

| 设置 | 说明 |
|---|---|
| 自动加白 | 总开关。关闭时不发任何请求，也不改动路由。 |
| 刷新间隔 | 每轮检查的间隔，1～3600 秒，默认 1 秒。修改后下一轮立即按新间隔执行。 |
| Token | 列表，每项为 token（`pgnfw_` 开头，不含空格与分隔符）、可选备注名、可选固定槽位 N（出口钉在槽位 N，不参与 FIFO 淘汰）。同一 token 不能重复添加。每个 token 各自查询自己的白名单、各自补加。 |
| 立即加白 | 手动执行一次 `POST …/add`。 |
| 查询状态 | 只读 `GET …/<token>`，**不会**占用白名单坑位。 |

从 po0.5 及更早版本升级时，原来逗号分隔的 token 字符串（含 `@N`）会自动转换成列表，旧的分钟间隔被忽略，刷新间隔取默认 1 秒。

状态区显示上次检查时间，以及每个 token 的结果：当前出口、白名单占用 `已用/上限`、每条白名单记录（`槽位 N` 表示固定槽位，`←` 表示当前出口所在网段）。
日志页以 `[APP] po0 firewall …` 记录结果变化与每次加白（token 只显示前 12 位）；结果不变的例行检查不写日志。

## 检查与加白

`Po0Firewall`（`lib/providers/po0_firewall.dart`）是常驻的 Riverpod notifier，在应用完成初始化（`initProvider` 变为 true）后启动。
设计取舍见 [ADR 0004](../adr/0004-per-second-read-only-polling.md) 与 [ADR 0005](../adr/0005-token-list-and-poll-interval.md)。

每轮对每个 token：

1. 只读 `GET …/<token>`（单次请求，5 秒超时）。
2. 当前出口不在白名单 → 走常规流程 `POST …/add`（设了固定槽位时为 `?slot=N`，失败重试 3 次）。
   设了固定槽位而出口在 FIFO 区时同样 `POST`，把它升级到固定槽位；出口已占用**其它**槽位时显示「槽位冲突」，不再反复请求。
3. 出口已在白名单、防火墙未启用、token 无效或请求失败 → 不写入。

一轮结束后等待一个刷新间隔再开始下一轮。默认 1 秒时，被其它设备按 FIFO 挤出白名单后约 1～2 秒内自动补回；间隔越长，补回越慢。
连续失败时按间隔的 2 / 4 / 8 / 16 倍退避，最长 30 秒（间隔本身超过 30 秒时不再额外退避），成功后恢复原间隔。

| 事件 | 行为 |
|---|---|
| 启动 | 立即检查 |
| 网络变化 | 丢弃复用的连接，清零退避，立即检查 |
| 回到前台 | 立即检查 |
| 增删 token 或改槽位 | 立即对当前列表执行一次加白（只改备注名不触发） |
| 修改刷新间隔 | 按新间隔安排下一轮 |
| 打开开关 | 先重新应用配置（写入直连路由），再执行一次加白 |
| Android 熄屏 | 暂停检查（不持有 WakeLock，不额外耗电） |
| Android 亮屏 | 立即检查并恢复按间隔检查 |

请求复用同一条 keep-alive 连接，避免每轮一次 TLS 握手；网络变化、超时或出错时丢弃连接重新建立。
检查在后台进行时页面不会显示「执行中」，只有手动操作才显示；手动操作若碰上正在进行的检查，会在其结束后立即执行。

### 生效范围

- 桌面端：应用运行期间持续检查；电脑休眠时自然暂停，唤醒后下一个间隔内恢复。
- Android：亮屏且 FlClash 在运行（前台或切到后台）时按间隔检查。检查逻辑运行在界面的 Flutter 引擎中，
  **从最近任务划掉 FlClash 后检查停止**（即使 VPN 仍在运行），重新打开应用即恢复。

## 为什么需要直连路由

服务端按**请求来源 IP**识别出口网段，所以请求必须从物理网卡直接发出：

1. 请求使用独立的 `HttpClient`，`findProxy` 固定为 `DIRECT`，绕过应用自身对 mixed-port 的代理设置（`FlClashHttpOverrides`）。
2. 开启后，生成的配置会：
   - 在规则最前面插入 `IP-CIDR,124.221.69.228/32,DIRECT,no-resolve`（规则模式下 TUN 捕获的流量也走直连）；
   - 向 `tun.route-exclude-address` 加入 `124.221.69.228/32`，桌面 TUN 不再接管该地址（全局模式同样有效）。
3. Android VPN 的路由表由 `VpnService.Builder` 决定，`excludeRoute` 需要 API 33，因此在 `sharedState` 中把
   `124.221.69.228/32` 从路由列表（默认 `0.0.0.0/0`）中拆分剔除。VPN 路由只在 VPN 启动时生效，所以 **Android 首次开启后需重启一次 VPN**。

证书校验沿用应用的「检查证书」开关（po0 端点使用 Let's Encrypt IP 证书，默认可正常校验）。

## 代码位置

| 文件 | 职责 |
|---|---|
| `lib/common/po0_firewall.dart` | token 解析、/24 比较、IPv4 路由剔除、keep-alive 直连传输、HTTP 客户端与响应解析、`po0NeedsWhitelist` |
| `lib/models/po0_firewall.dart` | `Po0FirewallProps`（持久化配置）与结果 / 状态模型 |
| `lib/providers/po0_firewall.dart` | 调度器 `Po0Firewall` 与 `po0FirewallClientProvider` |
| `lib/plugins/po0_screen.dart` / `android/.../plugins/Po0ScreenPlugin.kt` | Android 亮屏 / 熄屏信号（`$packageName/po0_screen` 通道） |
| `lib/providers/config.dart` | `po0FirewallSettingProvider`，并入 `Config`（随备份 / 恢复） |
| `lib/common/task.dart` | 生成配置时写入直连规则与 `route-exclude-address` |
| `lib/providers/state/system.dart` | Android VPN 路由剔除 |
| `lib/views/po0_firewall.dart` | po0 页面（概览、设置、token 卡片） |
| `lib/views/navigation.dart` / `lib/enum/enum.dart` | `PageLabel.po0` 主导航入口 |

测试：`test/common/po0_firewall_test.dart`、`test/providers/po0_firewall_test.dart`、`test/providers/state_derived_test.dart`、`test/providers/config_test.dart`、`test/views/po0_firewall_view_test.dart`。
