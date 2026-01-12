# Gemini HUD

A lightweight macOS utility that provides a fast, native, always-accessible
window for interacting with Gemini via the web.

This project is designed for personal productivity and learning purposes,
focusing on native macOS behaviors, clean architecture, and a smooth user
experience.

---

## ✨ Features

- Native macOS app (SwiftUI + AppKit)
- Embedded Gemini WebView
- Global keyboard shortcut
- Menu bar control
- Floating (always-on-top) window mode
- Clipboard-aware overlay with native paste behavior
- macOS blur & vibrancy (HUD-style UI)
- Window state persistence (size, position, visibility)

---

## 🚀 Usage

### Global Shortcut
- `⌥ + G` — Show / hide the Gemini window

### Clipboard Overlay
1. Copy any text (`⌘C`)
2. Open Gemini HUD
3. An overlay appears indicating clipboard content
4. Click **Paste** or press `⌘V`

---

## 🖥️ Requirements

- macOS (Apple Silicon or Intel)
- Xcode 15+
- macOS 14+ (recommended)

---

## 🛠️ Development

### Build & Run

1. Open the project in Xcode
2. Select the macOS target
3. Run (`⌘R`)

### Project Structure

* App/ App entry points
* Managers/ Window, WebView, and state management
* UI/ SwiftUI views and visual components
* Infrastructure/ Notifications and cross-cutting utilities


---

## 🔐 Security & Privacy

- No data is collected or transmitted by this app
- All interactions happen locally via WebView
- Clipboard access is explicit and user-initiated

---

## 📦 Distribution

This app is intended for personal use or sharing with a small number of
trusted colleagues.

When opening the app for the first time on another Mac:
- Right-click → Open → Confirm

---

## 📄 License

Personal / educational use.
