# FineWeather (初晴天气)

<p align="center">
  <img src="assets/images/app_preview.png" width="320" alt="FineWeather Main Screen" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/images/widget_preview.png" width="320" alt="Transparent Home Widgets" />
</p>

<p align="center">
  <b>A pure, elegant, ad-free, and lightweight modern weather app with fully transparent home widgets for Android, built with Flutter.</b>
  <br />
  <i>Zero Ads · Zero Tracking · Dual-Source Silent Failover (Open-Meteo & wttr.in) · Glassmorphic Design</i>
</p>

<p align="center">
  <a href="#-highlights--features">Features</a> •
  <a href="#-screenshots">Screenshots</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-build-from-source">Build</a> •
  <a href="#-license">License</a> •
  <a href="#-中文说明">中文说明</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Platform" />
  <img src="https://img.shields.io/badge/License-Apache--2.0-blue.svg" alt="License" />
  <img src="https://img.shields.io/badge/Author-sbitoh-informational" alt="Author" />
</p>

---

## 🌟 Highlights & Features

### 🛡️ 100% Pure & Distraction-Free
- **Zero Commercial Ads**: No startup splash ads, no banner popups, and no sponsored promotions.
- **No Newsfeeds or Spam**: Stripped of useless clickbait articles and redundant push notifications.
- **Privacy-Respecting**: No third-party tracking SDKs; location and weather data stay strictly local.

### 🌐 Dual Meteorological Sources with Zero-Config Failover
- **Primary Source**: [Open-Meteo](https://open-meteo.com/) high-resolution global weather models (conforming to WMO standards).
- **Secondary Source**: [wttr.in](https://wttr.in/) open weather API.
- **Automatic Silent Failover**: If the primary source is temporarily unreachable or times out, the app immediately switches to the backup source without requiring custom API keys or private proxy setups.

### 📱 Transparent Android Home Screen Widgets
- **4×1 Compact Ribbon Widget**: Large bold clock, localized city name, real-time temperature, condition status, and high/low range—engineered for single-line display with **zero text-wrapping or clipping**.
- **4×2 Weather Dashboard Widget**: Real-time clock with synchronized live date display (e.g. `Oct 17 Sat` / `10月17日 周六`), weather summary, and a 5-step hourly forecast timeline starting with `Now`.
- **100% Transparent Background**: Crisp white typography with delicate drop shadows, ensuring flawless legibility across light, dark, or busy wallpapers.
- **Clean Aesthetic**: Completely free of unnecessary application branding or system widget label clutter.

### 🧊 Glacial Glassmorphism Aesthetics
- Elegant Morandi cool-blue palette paired with soft glassmorphism cards and balanced whitespace for comfortable, strain-free viewing.

### 🌍 Seamless Bilingual Support (i18n)
- One-tap instant toggle between **English** and **Simplified Chinese (简体中文)**.
- Weather conditions, weekdays, dates, lifestyle metrics (*Gentle Breeze, Comfortable, Clear View*), and home widgets synchronize instantly.

### 📍 Localized Smart Geocoding
- Real-time GPS location with reverse geocoding via OpenStreetMap and BigDataCloud channels, accurately resolving the real local city name.

---

## 📸 Screenshots

| In-App Weather View | Transparent Home Widgets |
| :---: | :---: |
| <img src="assets/images/app_preview.png" width="340" alt="Main UI" /> | <img src="assets/images/widget_preview.png" width="340" alt="Widgets UI" /> |

---

## 🚀 Installation

Download the latest APK release from the [Releases](https://github.com/sbitoh/fineweather/releases) page:
- **Latest Version**: `v0.2.1`
- **Supported ABIs**: `arm64-v8a`, `armeabi-v7a`, `x86_64`

---

## 🛠️ Build from Source

### Prerequisites
- Flutter SDK `>=3.3.0`
- Android SDK (API 34/35, JDK 17)

### Steps
```bash
# 1. Clone repository
git clone https://github.com/sbitoh/fineweather.git
cd fineweather

# 2. Get dependencies
flutter pub get

# 3. Run debug build
flutter run

# 4. Build release APK
flutter build apk --release
```
Compiled APK path: `build/app/outputs/flutter-apk/app-release.apk`.

---

<br />

# 🇨🇳 中文说明

## 🌟 核心特性

- 🛡️ **极致纯粹，零商业侵扰**：没有开屏广告，没有资讯信息流与弹窗推送，还原天气本身应有的安宁。
- 🌐 **双气象源免 Key 静默容灾**：
  - 主源：**Open-Meteo** 全球高精度气象网（WMO 规范）。
  - 备用源：**wttr.in** 开放气象接口。
  - 主备源自动故障转移（Failover），客户端直连开箱即用。
- 📱 **原生全透明桌面小部件 (Home Widgets)**：
  - **4×1 单行条形小部件**：时间、城市、天气、温度与温差范围自适应排版，不挤压折行。
  - **4×2 气象看板大部件**：系统实时走日期、天气看板与 5 节点逐小时预报。
  - **100% 全透明背景**：白字带精细阴影，无论浅色天空还是暗色夜景壁纸均能清晰呈现。
  - **彻底去除应用标签**：桌面小部件彻底抹除多余系统标题，极简清爽。
- 🧊 **莫兰迪清透冰川蓝视觉**：毛玻璃卡片（Glassmorphism），视觉舒适护眼。
- 🌍 **双语与本地化联动 (i18n)**：简体中文与 English 一键热切换，应用内与桌面组件实时同步。
- 📍 **本地 GPS 逆地理识别**：精准解析本地真实城市名称。

---

## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE).

Developed with precision by **sbitoh**.
