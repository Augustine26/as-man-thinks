# As A Man Thinketh — Windows Desktop Popup App

A lightweight Windows desktop companion inspired by daily Bible verse popup apps, curated from James Allen's classic book *As A Man Thinketh* (covering all 7 chapters).

## Features
- **Sleek Desktop Popup Cards:** Displays dark-and-gold quote cards in the bottom-right corner of your screen and auto-dismisses after 25 seconds.
- **Zero-Dependency Windows Mode:** Runs natively on Windows via PowerShell & System Tray (`Start_AsAManThinketh.bat`) without requiring Python.
- **Python & Standalone `.exe` Support:** Includes a Tkinter desktop control panel (`AsAManThinketh_App.py`) and a GitHub Actions workflow that automatically builds a standalone `AsAManThinketh.exe`.
- **Customizable Schedule:** Trigger popups on demand or set intervals (15 mins, 1 hour, 3 hours).

---

## Quick Start (Windows — No Installation Needed)
1. Download or clone this repository.
2. Double-click **`Start_AsAManThinketh.bat`**.
3. Right-click the icon in your **Windows System Tray** (bottom-right near the clock) to show a thought immediately, change the timer interval, or exit.

### Run Automatically on Windows Startup
1. Press **`Win + R`**, type `shell:startup`, and press **Enter**.
2. Create a shortcut to **`Start_AsAManThinketh.bat`** and place it inside the Startup folder.

---

## Python & Building a `.exe` Locally
```bash
python AsAManThinketh_App.py
```

To build a single standalone Windows executable:
```bash
pip install pyinstaller
pyinstaller --onefile --windowed --name "AsAManThinketh" --add-data "quotes.json;." AsAManThinketh_App.py
```

> **Tip for GitHub:** Pushing to the `main` branch automatically triggers the included GitHub Actions workflow (`.github/workflows/build-exe.yml`) to compile `AsAManThinketh.exe` in the cloud—downloadable under the **Actions** tab!
