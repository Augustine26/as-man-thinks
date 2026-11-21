# As A Man Thinketh — Glassmorphism Desktop & Web Popup App

A frosted **glassmorphism** desktop and web companion with an **animated luminous stroke**, inspired by daily Bible verse popup apps and curated from James Allen's *As A Man Thinketh*.

## What's Included
1. **Native Windows Frosted Glass App (`Start_AsAManThinketh.bat` + `AsAManThinketh_GlassPopup.ps1`):**
   - Uses Windows Presentation Foundation (WPF) + Windows DWM Acrylic Blur (`ACCENT_ENABLE_BLURBEHIND`) for true frosted glass over your desktop wallpaper.
   - Features a continuously rotating gold-and-cyan animated border stroke, breathing glow, draggable glass card, and System Tray scheduler.
   - Runs in `-STA` mode with a persistent `DispatcherTimer` (fixing background loop exits).
2. **Web & GitHub Pages Version (`index.html`):**
   - Full CSS `backdrop-filter: blur(22px)` glassmorphism UI with `@property` rotating conic-gradient border stroke and native browser Desktop Notifications (`🔔 Enable Desktop Popups`).
   - Can be opened directly in any browser or hosted free via **GitHub Pages**.
3. **Python Desktop Version (`AsAManThinketh_App.py`):**
   - Translucent Tkinter companion with animated stroke border and GitHub Actions `.exe` build workflow.

## Quick Start on Windows
1. Extract the folder and double-click **`Start_AsAManThinketh.bat`**.
2. A frosted glass popup card appears immediately in the bottom-right corner.
3. Right-click the icon in your **Windows System Tray** (bottom-right near the clock) to trigger a popup anytime or change the timer interval.
