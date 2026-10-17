# 初晴天气 (FineWeather)

<p align="center">
  <img src="assets/images/app_preview.png" width="300" alt="FineWeather Preview" />
  <img src="assets/images/widget_preview.png" width="300" alt="Widgets Preview" />
</p>

<p align="center">
  <b>一款开源、纯净、优雅、极度轻量的现代化 Android / Flutter 天气应用与桌面微组件</b>
  <br />
  <i>零广告 · 零开屏 · 零隐私追踪 · 全球双源气象冗余容灾 · 全透明桌面小部件</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Platform" />
  <img src="https://img.shields.io/badge/License-Apache--2.0-blue.svg" alt="License" />
  <img src="https://img.shields.io/badge/Author-sbitoh-informational" alt="Author" />
</p>

---

## 🌟 核心特性 (Features)

- 🛡️ **极致纯粹，零商业侵扰**：没有开屏广告，没有资讯信息流，没有应用内弹框与后台唤醒，还原天气本身应有的安宁。
- 🌐 **双气象源免 Key 静默容灾**：
  - 主源：**Open-Meteo** 全球高精度气象网（WMO 规范）。
  - 备用源：**wttr.in** 开放气象接口。
  - 主备源自动故障转移（Failover），不依赖自建中转反代，客户端直连开箱即用。
- 📱 **原生透明桌面小部件 (Home Widgets)**：
  - **4×1 单行条形小部件**：实时大时钟、城市名称、实时温度、天气状态与高低温范围单行自适应排版，坚决不挤压折行。
  - **4×2 气象看板大部件**：时钟联动系统实时走日期（如 `10月17日 周六` / `Oct 17 Sat`）、当前天气、温湿体感与 5 节点逐小时预报。
  - **100% 全透明背景**：白字带精细阴影，无论浅色天空、暗色壁纸还是繁杂的城市夜景，均能完美清晰呈现。
  - **完全去除冗余应用标签**：桌面小部件彻底抹除“初晴天气”字样与小部件底部的多余系统标题，极简清爽。
- 🧊 **莫兰迪清透冰川蓝视觉**：
  - 毛玻璃卡片（Glassmorphism）与优雅的间距排版，视觉舒适护眼。
- 🌍 **双语与本地化无缝联动 (Bilingual & i18n)**：
  - 支持 **简体中文** 与 **English** 一键热切换。
  - 天气描述、日期与周几、生活指标（微风拂面、无需防护等）以及桌面组件均实时全局同步。
- 📍 **离线级本地 GPS 逆地理识别**：
  - GPS 结合 OpenStreetMap / BigDataCloud 双通道高精度逆地理编码，精准解析本地真实城市名称。

---

## 📸 界面预览 (Screenshots)

| 应用主界面 (Main App) | 桌面原生小部件 (Transparent Widgets) |
| :---: | :---: |
| <img src="assets/images/app_preview.png" width="360" /> | <img src="assets/images/widget_preview.png" width="360" /> |

---

## 🚀 快速安装 (Download & Install)

前往 [Releases](https://github.com/sbitoh/fineweather/releases) 页面下载最新的 APK 安装包：
- **最新版本**：`v0.2.1`
- **支持架构**：`arm64-v8a`, `armeabi-v7a`, `x86_64`

---

## 🛠️ 本地构建与开发 (Build from Source)

### 环境要求
- Flutter SDK `>=3.3.0`
- Android SDK (API 34 / 35, JDK 17)

### 构建步骤
```bash
# 克隆仓库
git clone https://github.com/sbitoh/fineweather.git
cd fineweather

# 获取依赖
flutter pub get

# 运行调试
flutter run

# 构建发布版 APK
flutter build apk --release
```
编译产物位于 `build/app/outputs/flutter-apk/app-release.apk`。

---

## 📄 开源许可 (License)

本项目基于 [Apache License 2.0](LICENSE) 协议开源。

开发者：**sbitoh**
