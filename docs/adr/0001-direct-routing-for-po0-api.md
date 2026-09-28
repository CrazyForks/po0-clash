# 0001. po0 API 请求的直连路由

- 状态：已采纳
- 日期：2026-09-27

## 背景

po0 服务端按请求来源 IP 加白。FlClash 运行时，应用自身的 HTTP 请求默认被 `FlClashHttpOverrides` 指向 mixed-port；
开启 TUN（桌面）或 VPN（Android）时，系统流量又会被 mihomo 接管。任何一条路径都会让加白请求从代理节点发出，
导致把节点 IP 加白、真实出口反而不在白名单。po0fw 的 README 也提示 TUN 用户手动添加 `IP-CIDR,124.221.69.228/32,DIRECT`。

备选方案：

1. 只在 Dart 侧使用 DIRECT 的 `HttpClient`：覆盖系统代理模式，但挡不住 TUN / VPN。
2. 只插入 DIRECT 规则：覆盖规则模式，但全局模式下 mihomo 不走规则。
3. 让内核（Go）代发请求：需要改 `core/` 协议与双端契约测试，成本高。
4. 在路由层把 API 地址排除出 TUN / VPN。

## 决定

组合 1 + 2 + 4，只在功能开启时生效：

- Dart 使用 `findProxy = DIRECT` 的独立 `HttpClient`。
- 生成配置时在规则最前插入 `IP-CIDR,124.221.69.228/32,DIRECT,no-resolve`，并写入 `tun.route-exclude-address`。
- Android 在 `sharedState` 中从 VPN 路由列表里拆分剔除该 /32（`excludeRoute` 需要 API 33，拆分方式兼容所有版本）。

## 后果

- 规则、全局、直连三种模式，系统代理 / TUN / Android VPN 三种接管方式下，请求都从物理网卡发出。
- Android 的 VPN 路由只在 VPN 启动时应用，首次开启功能后需重启 VPN；应用内提示已说明。
- 默认路由从单条 `0.0.0.0/0` 变为 32 条前缀，Android 按路由匹配回落到底层网络，与上游「绕过私有地址」模式的做法一致。
