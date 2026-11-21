import json
import os
import random
import tkinter as tk
from tkinter import ttk

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
QUOTES_FILE = os.path.join(BASE_DIR, "quotes.json")

with open(QUOTES_FILE, "r", encoding="utf-8") as f:
    QUOTES = json.load(f)


class AsAManThinkethApp:
    def __init__(self, root):
        self.root = root
        self.root.title("As A Man Thinketh — Desktop Companion")
        self.root.geometry("460x320")
        self.root.configure(bg="#1C2026")
        self.root.resizable(False, False)

        self.interval_minutes = tk.IntVar(value=60)
        self.current_quote = random.choice(QUOTES)
        self.popup_window = None

        self._build_main_ui()
        self.show_popup()
        self.schedule_next_popup()

    def _build_main_ui(self):
        # Gold top accent
        tk.Frame(self.root, bg="#D4AF37", height=4).pack(fill="x")

        header = tk.Label(
            self.root,
            text="AS A MAN THINKETH",
            font=("Segoe UI", 13, "bold"),
            fg="#D4AF37",
            bg="#1C2026"
        )
        header.pack(pady=(16, 2))

        sub = tk.Label(
            self.root,
            text="James Allen • Daily Desktop Thought Popups",
            font=("Segoe UI", 9),
            fg="#A0AAB4",
            bg="#1C2026"
        )
        sub.pack(pady=(0, 14))

        # Current quote preview box
        card = tk.Frame(self.root, bg="#252A32", padx=16, pady=14)
        card.pack(fill="both", expand=True, padx=20)

        self.chapter_lbl = tk.Label(
            card,
            text=self.current_quote["chapter"].upper(),
            font=("Segoe UI", 8, "bold"),
            fg="#D4AF37",
            bg="#252A32",
            anchor="w"
        )
        self.chapter_lbl.pack(fill="x")

        self.quote_lbl = tk.Label(
            card,
            text=f'"{self.current_quote["quote"]}"',
            font=("Georgia", 10, "italic"),
            fg="#F2F4F8",
            bg="#252A32",
            wraplength=385,
            justify="left"
        )
        self.quote_lbl.pack(fill="both", expand=True, pady=(6, 0))

        # Controls bar
        controls = tk.Frame(self.root, bg="#1C2026")
        controls.pack(fill="x", padx=20, pady=14)

        tk.Label(
            controls,
            text="Popup every (mins):",
            font=("Segoe UI", 9),
            fg="#A0AAB4",
            bg="#1C2026"
        ).pack(side="left")

        interval_box = ttk.Combobox(
            controls,
            textvariable=self.interval_minutes,
            values=[1, 15, 30, 60, 120, 180],
            width=5,
            state="readonly"
        )
        interval_box.pack(side="left", padx=(6, 12))

        tk.Button(
            controls,
            text="Test Popup Now",
            command=self.show_popup,
            bg="#D4AF37",
            fg="#1C2026",
            font=("Segoe UI", 9, "bold"),
            relief="flat",
            padx=10,
            pady=4,
            cursor="hand2"
        ).pack(side="right")

        tk.Button(
            controls,
            text="Minimize",
            command=self.root.iconify,
            bg="#2F3640",
            fg="#F2F4F8",
            font=("Segoe UI", 9),
            relief="flat",
            padx=10,
            pady=4,
            cursor="hand2"
        ).pack(side="right", padx=(0, 8))

    def show_popup(self):
        self.current_quote = random.choice(QUOTES)
        self.chapter_lbl.config(text=self.current_quote["chapter"].upper())
        self.quote_lbl.config(text=f'"{self.current_quote["quote"]}"')

        if self.popup_window and self.popup_window.winfo_exists():
            self.popup_window.destroy()

        popup = tk.Toplevel(self.root)
        self.popup_window = popup
        popup.overrideredirect(True)
        popup.attributes("-topmost", True)
        popup.configure(bg="#1C2026")

        width, height = 420, 210
        screen_w = popup.winfo_screenwidth()
        screen_h = popup.winfo_screenheight()
        x = screen_w - width - 20
        y = screen_h - height - 60
        popup.geometry(f"{width}x{height}+{x}+{y}")

        tk.Frame(popup, bg="#D4AF37", height=4).pack(fill="x")

        top_bar = tk.Frame(popup, bg="#1C2026")
        top_bar.pack(fill="x", padx=16, pady=(12, 4))

        tk.Label(
            top_bar,
            text=f"AS A MAN THINKETH  •  {self.current_quote['chapter'].upper()}",
            font=("Segoe UI", 8, "bold"),
            fg="#D4AF37",
            bg="#1C2026"
        ).pack(side="left")

        close_btn = tk.Label(
            top_bar,
            text="✕",
            font=("Segoe UI", 10, "bold"),
            fg="#A0AAB4",
            bg="#1C2026",
            cursor="hand2"
        )
        close_btn.pack(side="right")
        close_btn.bind("<Button-1>", lambda e: popup.destroy())

        tk.Label(
            popup,
            text=f'"{self.current_quote["quote"]}"',
            font=("Georgia", 11, "italic"),
            fg="#F2F4F8",
            bg="#1C2026",
            wraplength=385,
            justify="left"
        ).pack(fill="both", expand=True, padx=16, pady=(4, 6))

        bottom_bar = tk.Frame(popup, bg="#1C2026")
        bottom_bar.pack(fill="x", padx=16, pady=(0, 14))

        tk.Label(
            bottom_bar,
            text="— James Allen",
            font=("Segoe UI", 9),
            fg="#A0AAB4",
            bg="#1C2026"
        ).pack(side="left")

        tk.Button(
            bottom_bar,
            text="Next Thought →",
            command=self.show_popup,
            bg="#D4AF37",
            fg="#1C2026",
            font=("Segoe UI", 8, "bold"),
            relief="flat",
            padx=10,
            pady=3,
            cursor="hand2"
        ).pack(side="right")

        # Auto-dismiss after 25 seconds
        popup.after(25000, lambda: popup.destroy() if popup.winfo_exists() else None)

    def schedule_next_popup(self):
        ms = int(self.interval_minutes.get()) * 60 * 1000
        self.root.after(ms, self._timer_trigger)

    def _timer_trigger(self):
        self.show_popup()
        self.schedule_next_popup()


if __name__ == "__main__":
    root = tk.Tk()
    app = AsAManThinkethApp(root)
    root.mainloop()
