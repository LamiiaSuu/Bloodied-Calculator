import tkinter as tk
from tkinter import ttk


class HPThresholdTracker:
    def __init__(self, root):
        self.root = root
        self.root.title("HP Threshold Tracker")

        # Larger font
        default_font = ("Segoe UI", 12)
        self.root.option_add("*Font", default_font)

        self.enemy_rows = []
        self.graveyard = []
        self.graveyard_expanded = False
        self.heal_mode = False

        self.marker_options = []

        self.condition_options = [
            "Off-Guard",
            "Prone",
            "Persistent Damage",
            "Grabbed",
            "Restrained",
            "Concealed",
            "Hidden",
            "Invisible",
            "Flying",
            "Frightened",
            "Sickened",
            "Clumsy",
            "Drained",
            "Doomed",
            "Enfeebled",
            "Slowed",
            "Stupefied",
            "Wounded",
            "Dying",
            "Special"
        ]

        for color in ["RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "PURPLE"]:
            for number in range(1, 10):
                self.marker_options.append(f"{color} {number}")

        main = ttk.Frame(root, padding=10)
        main.pack(fill="both", expand=True)

        # Steps
        ttk.Label(main, text="Steps:").grid(row=0, column=0, sticky="w")

        ttk.Button(
            main,
            text="RESET",
            command=self.reset_encounter
        ).grid(
            row=0,
            column=2,
            padx=5,
            pady=10,
            sticky="w"
        )

        mode_text = "HEAL" if self.heal_mode else "DMG"

        self.mode_button = ttk.Button(
            main,
            text="Heal / DMG (DMG)",
            command=self.toggle_heal_mode
        )

        self.mode_button.grid(
            row=0,
            column=3,
            padx=25,
            pady=(0, 8)
        )

        self.steps_var = tk.StringVar(value="4")
        self.steps_var.trace_add("write", self.calculate_all)

        ttk.Entry(
            main,
            textvariable=self.steps_var,
            width=5
        ).grid(row=0, column=1, sticky="w")

        # Enemies
        self.enemies_frame = ttk.Frame(main)
        self.enemies_frame.grid(
            row=1,
            column=0,
            columnspan=10,
            sticky="w",
            pady=(10, 0)
        )

        # Graveyard
        self.graveyard_frame = ttk.Frame(main)
        self.graveyard_frame.grid(
            row=2,
            column=0,
            columnspan=10,
            sticky="w",
            pady=(15, 0)
        )

        # Start with 5 enemies
        for _ in range(5):
            self.add_enemy()



    def get_status(self, max_hp, current_hp):
        if max_hp <= 0:
            return "Unknown", "black"

        ratio = current_hp / max_hp

        if ratio > 0.75:
            return "Healthy", "black"
        elif ratio > 0.50:
            return "Wounded", "green"
        elif ratio > 0.25:
            return "Bloodied", "orange"
        else:
            return "Critical", "red"


    def toggle_heal_mode(self):
        self.heal_mode = not self.heal_mode

        mode_text = "HEAL" if self.heal_mode else "DMG"

        self.mode_button.config(
            text=f"Heal / DMG ({mode_text})"
        )

        self.refresh_layout()

    def calculate_all(self, *args):
        try:
            steps = int(self.steps_var.get())

            if steps < 2:
                return

            for enemy in self.enemy_rows:
                max_text = enemy["max_hp"].get().strip()
                cur_text = enemy["current_hp"]["text"]

                if not max_text:
                    enemy["thresholds"].config(text="")
                    enemy["status"].config(text="")
                    continue

                max_hp = int(max_text)

                thresholds = []

                for s in range(1, steps):
                    percent = (steps - s) * 100 // steps
                    value = max_hp * (steps - s) // steps

                    thresholds.append(f"{percent}%:{value}")

                enemy["thresholds"].config(
                    text="   ".join(thresholds)
                )

                if cur_text != "-":
                    current_hp = int(cur_text)

                    status_text, color = self.get_status(
                        max_hp,
                        current_hp
                    )

                    enemy["status"].config(
                        text=status_text,
                        fg=color
                    )
                else:
                    enemy["status"].config(text="")

        except ValueError:
            pass

    def damage_enemy(self, enemy, damage):
        try:
            max_hp = int(enemy["max_hp"].get())

            current_text = enemy["current_hp"]["text"]

            # Noch kein Schaden eingetragen
            if current_text == "-":
                current_hp = max_hp
            else:
                current_hp = int(current_text)

            if self.heal_mode:
                current_hp = min(max_hp, current_hp + damage)
            else:
                current_hp = max(0, current_hp - damage)

            enemy["current_hp"].config(
                text=str(current_hp)
            )

            self.calculate_all()

        except ValueError:
            pass

    def add_enemy(self):
        enemy_number = len(self.enemy_rows) + 1

        enemy_number = len(self.enemy_rows) + 1

        default_marker = f"RED {((enemy_number - 1) % 9) + 1}"

        marker_var = tk.StringVar(value=default_marker)

        marker_combo = ttk.Combobox(
            self.enemies_frame,
            values=self.marker_options,
            textvariable=marker_var,
            width=10,
            state="readonly"
        )

        marker_display = tk.Label(
            self.enemies_frame,
            text="1",
            width=2,
            font=("Segoe UI", 14, "bold")
        )
        name_entry = ttk.Entry(
            self.enemies_frame,
            width=20
        )
        name_entry.insert(0, f"Enemy {enemy_number}")

        max_hp_entry = ttk.Entry(
            self.enemies_frame,
            width=8
        )

        current_hp_label = tk.Label(
            self.enemies_frame,
            text="-",
            width=8
        )
        prefix = "+" if self.heal_mode else "-"
        minus10 = ttk.Button(
            self.enemies_frame,
            text=f"{prefix}10",
            width=4
        )

        minus5 = ttk.Button(
            self.enemies_frame,
            text=f"{prefix}5",
            width=3
        )

        minus2 = ttk.Button(
            self.enemies_frame,
            text=f"{prefix}2",
            width=3
        )

        minus1 = ttk.Button(
            self.enemies_frame,
            text=f"{prefix}1",
            width=3
        )
        max_hp_entry.bind("<KeyRelease>", self.calculate_all)

        status_label = tk.Label(
            self.enemies_frame,
            text="",
            width=10
        )

        thresholds_label = ttk.Label(
            self.enemies_frame,
            text="",
            width=25
        )

        enemy = {
            "marker_var": marker_var,
            "marker_combo": marker_combo,
            "marker_display": marker_display,
            "name": name_entry,
            "max_hp": max_hp_entry,
            "current_hp": current_hp_label,
            "status": status_label,
            "thresholds": thresholds_label,
            "conditions": [],
            "conditions_label": tk.Label(
                self.enemies_frame,
                text="",
                anchor="w",
                justify="left"
            )
        }

        self.update_conditions_display(enemy)
        enemy["minus10"] = minus10
        enemy["minus5"] = minus5
        enemy["minus2"] = minus2
        enemy["minus1"] = minus1
        minus10.config(
            command=lambda e=enemy: self.damage_enemy(e, 10)
        )

        minus5.config(
            command=lambda e=enemy: self.damage_enemy(e, 5)
        )

        minus2.config(
            command=lambda e=enemy: self.damage_enemy(e, 2)
        )

        minus1.config(
            command=lambda e=enemy: self.damage_enemy(e, 1)
        )
        enemy["marker_var"].trace_add(
            "write",
            lambda *args, e=enemy: self.update_marker_display(e)
        )

        self.update_marker_display(enemy)

        dead_button = ttk.Button(
            self.enemies_frame,
            text="DEAD",
            command=lambda e=enemy: self.mark_dead(e)
        )

        conditions_button = ttk.Button(
            self.enemies_frame,
            text="Conditions",
            command=lambda e=enemy: self.open_conditions_window(e)
        )

        enemy["conditions_button"] = conditions_button

        enemy["dead_button"] = dead_button

        self.enemy_rows.append(enemy)

        self.refresh_layout()

    def open_conditions_window(self, enemy):
        window = tk.Toplevel(self.root)
        window.title(f"Conditions - {enemy['name'].get()}")

        ttk.Label(
            window,
            text="Condition:"
        ).grid(row=0, column=0, padx=5, pady=5)

        condition_var = tk.StringVar(
            value=self.condition_options[0]
        )

        ttk.Combobox(
            window,
            values=self.condition_options,
            textvariable=condition_var,
            state="readonly",
            width=25
        ).grid(
            row=0,
            column=1,
            columnspan=6,
            padx=5,
            pady=5,
            sticky="w"
        )

        listbox = tk.Listbox(
            window,
            width=40,
            height=10
        )

        listbox.grid(
            row=1,
            column=0,
            columnspan=7,
            padx=5,
            pady=5
        )

        def refresh_list():
            listbox.delete(0, tk.END)

            for condition, value in enemy["conditions"]:
                if value is None:
                    listbox.insert(
                        tk.END,
                        condition
                    )
                else:
                    listbox.insert(
                        tk.END,
                        f"{condition} {value}"
                    )

        def add_or_increase(amount):
            condition_name = condition_var.get()

            for i, (condition, value) in enumerate(enemy["conditions"]):
                if condition == condition_name:

                    if value is None:
                        if amount is not None:
                            enemy["conditions"][i] = (
                                condition,
                                amount
                            )

                    else:
                        if amount is not None:
                            enemy["conditions"][i] = (
                                condition,
                                value + amount
                            )

                    self.update_conditions_display(enemy)
                    refresh_list()
                    return

            enemy["conditions"].append(
                (condition_name, amount)
            )

            self.update_conditions_display(enemy)
            refresh_list()

        def modify_selected(amount):
            selection = listbox.curselection()

            if not selection:
                return

            index = selection[0]

            condition, value = enemy["conditions"][index]

            if amount is None:
                del enemy["conditions"][index]

            elif value is None:
                del enemy["conditions"][index]

            else:
                new_value = value - amount

                if new_value <= 0:
                    del enemy["conditions"][index]
                else:
                    enemy["conditions"][index] = (
                        condition,
                        new_value
                    )

            self.update_conditions_display(enemy)
            refresh_list()

        # ADD BUTTONS
        ttk.Button(
            window,
            text="ADD",
            command=lambda: add_or_increase(None)
        ).grid(row=2, column=0, padx=2, pady=5)

        ttk.Button(
            window,
            text="+1",
            command=lambda: add_or_increase(1)
        ).grid(row=2, column=1, padx=2)

        ttk.Button(
            window,
            text="+2",
            command=lambda: add_or_increase(2)
        ).grid(row=2, column=2, padx=2)

        ttk.Button(
            window,
            text="+3",
            command=lambda: add_or_increase(3)
        ).grid(row=2, column=3, padx=2)

        ttk.Button(
            window,
            text="+4",
            command=lambda: add_or_increase(4)
        ).grid(row=2, column=4, padx=2)

        ttk.Button(
            window,
            text="+5",
            command=lambda: add_or_increase(5)
        ).grid(row=2, column=5, padx=2)

        # REMOVE BUTTONS
        ttk.Button(
            window,
            text="REMOVE",
            command=lambda: modify_selected(None)
        ).grid(row=3, column=0, padx=2, pady=5)

        ttk.Button(
            window,
            text="-1",
            command=lambda: modify_selected(1)
        ).grid(row=3, column=1, padx=2)

        ttk.Button(
            window,
            text="-2",
            command=lambda: modify_selected(2)
        ).grid(row=3, column=2, padx=2)

        ttk.Button(
            window,
            text="-3",
            command=lambda: modify_selected(3)
        ).grid(row=3, column=3, padx=2)

        ttk.Button(
            window,
            text="-4",
            command=lambda: modify_selected(4)
        ).grid(row=3, column=4, padx=2)

        ttk.Button(
            window,
            text="-5",
            command=lambda: modify_selected(5)
        ).grid(row=3, column=5, padx=2)

        refresh_list()
    
    def update_conditions_display(self, enemy):
        badges = []

        for condition, value in enemy["conditions"]:
            short = condition[:3]

            if value is None:
                badges.append(f"[{short}]")
            else:
                badges.append(f"[{short} {value}]")

        enemy["conditions_label"].config(
            text=" ".join(badges)
        )

        enemy["conditions_label"].config(
            text=" ".join(badges)
        )

    def mark_dead(self, enemy):
        name = enemy["name"].get() or "Unknown"
        max_hp = enemy["max_hp"].get() or "?"
        current_hp = enemy["current_hp"].cget("text")

        if current_hp == "-":
            current_hp = "?"

        self.graveyard.append(
            f"{name} (Max:{max_hp}, Current:{current_hp})"
        )

        enemy["name"].destroy()
        enemy["max_hp"].destroy()
        enemy["current_hp"].destroy()
        enemy["status"].destroy()
        enemy["thresholds"].destroy()
        enemy["dead_button"].destroy()
        enemy["marker_combo"].destroy()
        enemy["marker_display"].destroy()
        enemy["minus10"].destroy()
        enemy["minus5"].destroy()
        enemy["minus2"].destroy()
        enemy["minus1"].destroy()

        self.enemy_rows.remove(enemy)

        if not self.enemy_rows:
            self.add_enemy()

        self.refresh_layout()
        self.refresh_graveyard()

    def update_marker_display(self, enemy):
        selection = enemy["marker_var"].get()

        color_name, number = selection.split()

        color_map = {
            "RED": "red",
            "ORANGE": "orange",
            "YELLOW": "#d4b000",
            "GREEN": "green",
            "BLUE": "blue",
            "PURPLE": "purple"
        }

        enemy["marker_display"].config(
            text=number,
            fg=color_map[color_name]
        )

    def remove_last_enemy(self):
        if len(self.enemy_rows) <= 1:
            return

        enemy = self.enemy_rows.pop()

        enemy["name"].destroy()
        enemy["max_hp"].destroy()
        enemy["current_hp"].destroy()
        enemy["status"].destroy()
        enemy["thresholds"].destroy()
        enemy["dead_button"].destroy()
        enemy["marker_combo"].destroy()
        enemy["marker_display"].destroy()
        enemy["minus10"].destroy()
        enemy["minus5"].destroy()
        enemy["minus2"].destroy()
        enemy["minus1"].destroy()

        self.refresh_layout()

    def toggle_graveyard(self):
        self.graveyard_expanded = not self.graveyard_expanded
        self.refresh_graveyard()

    def refresh_graveyard(self):
        for widget in self.graveyard_frame.winfo_children():
            widget.destroy()

        arrow = "▼" if self.graveyard_expanded else "▶"

        ttk.Button(
            self.graveyard_frame,
            text=f"{arrow} Graveyard ({len(self.graveyard)})",
            command=self.toggle_graveyard
        ).pack(anchor="w")

        if self.graveyard_expanded:
            for index, dead_enemy in enumerate(self.graveyard):
                row = ttk.Frame(self.graveyard_frame)
                row.pack(anchor="w", fill="x")

                ttk.Label(
                    row,
                    text=dead_enemy
                ).pack(side="left")

                ttk.Button(
                    row,
                    text="-",
                    width=3,
                    command=lambda i=index: self.delete_graveyard_entry(i)
                ).pack(side="left", padx=5)

    def delete_graveyard_entry(self, index):
        del self.graveyard[index]
        self.refresh_graveyard()

    def reset_encounter(self):
        if not self.enemy_rows:
            return

        for enemy in self.enemy_rows:
            enemy["name"].destroy()
            enemy["max_hp"].destroy()
            enemy["current_hp"].destroy()
            enemy["status"].destroy()
            enemy["thresholds"].destroy()
            enemy["dead_button"].destroy()
            enemy["marker_combo"].destroy()
            enemy["marker_display"].destroy()
            enemy["minus10"].destroy()
            enemy["minus5"].destroy()
            enemy["minus2"].destroy()
            enemy["minus1"].destroy()

        self.enemy_rows.clear()
        self.graveyard.clear()

        self.next_marker_number = 1

        for _ in range(5):
            self.add_enemy()

        self.refresh_graveyard()

    def refresh_layout(self):

        for widget in self.enemies_frame.winfo_children():
            widget.grid_forget()

        for i, enemy in enumerate(self.enemy_rows):
            enemy["marker_combo"].grid(
                row=i,
                column=0,
                padx=3
            )

            enemy["marker_display"].grid(
                row=i,
                column=1,
                padx=3
            )

            enemy["name"].grid(
                row=i,
                column=2,
                padx=5,
                pady=3
            )

            enemy["conditions_label"].grid(
                row=i,
                column=11,
                sticky="w"
            )

            enemy["max_hp"].grid(
                row=i,
                column=3,
                padx=5
            )

            enemy["current_hp"].grid(
                row=i,
                column=4,
                padx=5
            )

            prefix = "+" if self.heal_mode else "-"

            enemy["minus10"].config(text=f"{prefix}10")
            enemy["minus5"].config(text=f"{prefix}5")
            enemy["minus2"].config(text=f"{prefix}2")
            enemy["minus1"].config(text=f"{prefix}1")

            enemy["minus10"].grid(
                row=i,
                column=5,
                padx=1
            )

            enemy["minus5"].grid(
                row=i,
                column=6,
                padx=1
            )

            enemy["minus2"].grid(
                row=i,
                column=7,
                padx=1
            )

            enemy["minus1"].grid(
                row=i,
                column=8,
                padx=1
            )

            enemy["status"].grid(
                row=i,
                column=9,
                padx=5
            )

            enemy["thresholds"].grid(
                row=i,
                column=10,
                sticky="w"
            )

            enemy["conditions_button"].grid(
                row=i,
                column=12,
                padx=5
            )

            enemy["dead_button"].grid(
                row=i,
                column=13,
                padx=5
            )
            

        button_row = len(self.enemy_rows)
    

        ttk.Button(
            self.enemies_frame,
            text="+",
            width=3,
            command=self.add_enemy
        ).grid(
            row=button_row,
            column=2,
            pady=10,
            sticky="w"
        )

        self.refresh_graveyard()


root = tk.Tk()
app = HPThresholdTracker(root)
root.mainloop()