import json
import os
import random
import tkinter as tk
from tkinter import ttk

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
QUOTES_FILE = os.path.join(BASE_DIR, "quotes.json")

with open(QUOTES_FILE, "r", encoding="utf-8") as f:
    QUOTES = json.load(f)


class AsAManThinkethGlassApp:
    def __init__(self, root):
        self.root = root
        self.root.title("As A Man Thinketh — Glass Companion")
        self.root.geometry("460x320")
        self.root.configure(bg="#0F141E")
        self.root.resizable(False, False)

        self.interval_minutes = tk.IntVar(value=60)
        self.current_quote = random.choice(QUOTES)
        self.popup_window = None
        self.stroke_phase = 0

        self._build_main_ui()
        self.show_popup()
        self.schedule_next_popup()

    def _build_main_ui(self):
        tk.Frame(self.root, bg="#F5D061", height=3).pack(fill="x")

        tk.Label(
            self.root,
            text="AS A MAN THINKETH",
            font=("Segoe UI", 13, "bold"),
            fg="#F5D061",
            bg="#0F141E"
        ).pack(pady=(16, 2))

        tk.Label(
            self.root,
            text="James Allen • Glassmorphism Desktop Popups",
            font=("Segoe UI", 9),
            fg="#94A3B8",
            bg="#0F141E"
        ).pack(pady=(0, 14))

        card = tk.Frame(self.root, bg="#161D2B", padx=18, pady=14, highlightbackground="#F5D061", highlightthickness=1)
        card.pack(fill="both", expand=True, padx=20)

        self.chapter_lbl = tk.Label(
            card,
            text=self.current_quote["chapter"].upper(),
            font=("Segoe UI", 8, "bold"),
            fg="#F5D061",
            bg="#161D2B",
            anchor="w"
        )
        self.chapter_lbl.pack(fill="x")

        self.quote_lbl = tk.Label(
            card,
            text=f'"{self.current_quote["quote"]}"',
            font=("Georgia", 10, "italic"),
            fg="#F8FAFC",
            bg="#161D2B",
            wraplength=380,
            justify="left"
        )
        self.quote_lbl.pack(fill="both", expand=True, pady=(6, 0))

        controls = tk.Frame(self.root, bg="#0F141E")
        controls.pack(fill="x", padx=20, pady=14)

        tk.Label(
            controls,
            text="Interval (mins):",
            font=("Segoe UI", 9),
            fg="#94A3B8",
            bg="#0F141E"
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
            text="Show Popup",
            command=self.show_popup,
            bg="#F5D061",
            fg="#0F172A",
            font=("Segoe UI", 9, "bold"),
            relief="flat",
            padx=12,
            pady=4,
            cursor="hand2"
        ).pack(side="right")

        tk.Button(
            controls,
            text="Minimize",
            command=self.root.iconify,
            bg="#1E293B",
            fg="#F8FAFC",
            font=("Segoe UI", 9),
            relief="flat",
            padx=10,
            pady=4,
            cursor="hand2"
        ).pack(side="right", padx=(0, 8))

    def _animate_stroke(self, border_frame, popup):
        if not popup.winfo_exists():
            return
        colors = ["#F5D061", "#EAB308", "#38BDF8", "#818CF8", "#F5D061"]
        border_frame.config(bg=colors[self.stroke_phase % len(colors)])
        self.stroke_phase += 1
        popup.after(700, lambda: self._animate_stroke(border_frame, popup))

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
        popup.attributes("-alpha", 0.92)  # Translucent glass opacity

        width, height = 430, 215
        screen_w = popup.winfo_screenwidth()
        screen_h = popup.winfo_screenheight()
        x = screen_w - width - 20
        y = screen_h - height - 60
        popup.geometry(f"{width}x{height}+{x}+{y}")

        # Animated outer stroke frame
        stroke_frame = tk.Frame(popup, bg="#F5D061", padx=2, pady=2)
        stroke_frame.pack(fill="both", expand=True)

        inner = tk.Frame(stroke_frame, bg="#141A26", padx=16, pady=12)
        inner.pack(fill="both", expand=True)

        top_bar = tk.Frame(inner, bg="#141A26")
        top_bar.pack(fill="x", pady=(0, 6))

        tk.Label(
            top_bar,
            text=f"AS A MAN THINKETH  •  {self.current_quote['chapter'].upper()}",
            font=("Segoe UI", 8, "bold"),
            fg="#F5D061",
            bg="#141A26"
        ).pack(side="left")

        close_btn = tk.Label(
            top_bar,
            text="✕",
            font=("Segoe UI", 10, "bold"),
            fg="#94A3B8",
            bg="#141A26",
            cursor="hand2"
        )
        close_btn.pack(side="right")
        close_btn.bind("<Button-1>", lambda e: popup.destroy())

        tk.Label(
            inner,
            text=f'"{self.current_quote["quote"]}"',
            font=("Georgia", 11, "italic"),
            fg="#F8FAFC",
            bg="#141A26",
            wraplength=388,
            justify="left"
        ).pack(fill="both", expand=True, pady=(2, 6))

        bottom_bar = tk.Frame(inner, bg="#141A26")
        bottom_bar.pack(fill="x", pady=(4, 0))

        tk.Label(
            bottom_bar,
            text="— James Allen",
            font=("Segoe UI", 9),
            fg="#94A3B8",
            bg="#141A26"
        ).pack(side="left")

        tk.Button(
            bottom_bar,
            text="Next Thought →",
            command=self.show_popup,
            bg="#F5D061",
            fg="#0F172A",
            font=("Segoe UI", 8, "bold"),
            relief="flat",
            padx=12,
            pady=3,
            cursor="hand2"
        ).pack(side="right")

        self._animate_stroke(stroke_frame, popup)
        popup.after(25000, lambda: popup.destroy() if popup.winfo_exists() else None)

    def schedule_next_popup(self):
        ms = int(self.interval_minutes.get()) * 60 * 1000
        self.root.after(ms, self._timer_trigger)

    def _timer_trigger(self):
        self.show_popup()
        self.schedule_next_popup()


if __name__ == "__main__":
    root = tk.Tk()
    app = AsAManThinkethGlassApp(root)
    root.mainloop()
