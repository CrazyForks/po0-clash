# po0-clash

[**简体中文**](README_zh_CN.md)

A multi-platform proxy client based on [FlClash](https://github.com/chen08209/FlClash), with a built-in po0 firewall
auto-whitelist (port of [po0fw](https://github.com/w0ven/po0fw)) and a HeroUI-style UI on Windows and macOS.

po0-clash is a standalone app with its own app id, installer, process and service names and data directory, so it
installs and runs side by side with official FlClash.

<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="docs/features/images/ui_po0_dark.png">
        <img alt="The po0 page of po0-clash" src="docs/features/images/ui_po0_light.png" width="90%">
    </picture>
</p>

## Features

- **po0 auto-whitelist**: add a `pgnfw_` token for each po0 machine. While the app is open it checks the whitelist at
  the refresh interval (5 seconds by default) and adds your exit IP as soon as it is missing, whether or not the proxy is
  on. The request always goes direct, so the real exit is whitelisted rather than the proxy's.
- **HeroUI-style desktop UI**: grouped settings cards, page fades and sidebar motion.
- Everything FlClash already does: ClashMeta core, subscription import, WebDAV sync, dark mode and more.

## Install

Download the file for your platform from [Releases](https://github.com/yuuuki-creation/po0-clash/releases).

| Platform | How |
|---|---|
| Windows | Run `po0-clash-<version>-windows-amd64-setup.exe`, or unzip the `.zip` for a portable copy. It does not touch an installed official FlClash |
| macOS | Run the command below in Terminal; it picks Apple Silicon or Intel and installs `/Applications/po0-clash.app` |
| Android | Install `po0-clash-<version>-android-arm64-v8a.apk`. No need to uninstall official FlClash; both can be installed |
| Linux / iOS | Not provided |

```bash
curl -fsSL https://raw.githubusercontent.com/yuuuki-creation/po0-clash/main/scripts/install-macos.sh | bash
```

Set `PO0CLASH_VERSION` (a release tag such as `v5.0.0`) or `PO0CLASH_DMG` (a local dmg or URL) before `bash` to pick a
specific build. The macOS build is not notarized; the script removes the quarantine attribute. More options are in
[docs/install.md](docs/install.md) (Chinese).

Only turn the system proxy or TUN on in one proxy client at a time; two clients fight over it.

### Coming from the old FlClash-po0 builds

The `v0.8.98-po0.N` builds installed themselves as FlClash, and po0-clash does not replace them. Export a local backup
file from **Backup and restore** in the old app and import it into po0-clash (or just re-enter your po0 tokens), then
uninstall the old app yourself. It will not receive further updates.

## Using the po0 whitelist

1. Open **po0** in the main navigation.
2. Add your tokens (optionally with a name) and turn on **Auto whitelist**.
3. On Android, restart the VPN once after the first time you enable it so the direct route takes effect.

## Development

Goals, feature designs, build and release process are in [docs/](docs/README.md) (Chinese); coding rules are in
[AGENTS.md](AGENTS.md).

## Credits and license

- [chen08209/FlClash](https://github.com/chen08209/FlClash): the upstream client
- [w0ven/po0fw](https://github.com/w0ven/po0fw): the po0 firewall whitelist logic

Released under [GPL-3.0](LICENSE), like upstream.
