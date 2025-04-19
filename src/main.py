import os
import json
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import threading

CONFIG_PATH = "C:/blender_headless_tools/config.json"
SCRIPTS_DIR = "C:/blender_headless_tools/scripts"
LOG_PATH = "C:/blender_headless_tools/log.txt"

# Ensure the working directories exist
def ensure_dirs():
    os.makedirs(SCRIPTS_DIR, exist_ok=True)
    os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)

# Load config from file
def load_config():
    if os.path.exists(CONFIG_PATH):
        with open(CONFIG_PATH, 'r') as f:
            return json.load(f)
    return {}

# Save config to file
def save_config(config):
    with open(CONFIG_PATH, 'w') as f:
        json.dump(config, f)

# Generate split-by-context script only
def generate_split_script():
    script_code = '''import bpy\nimport os\n\nbasename, ext = os.path.splitext(bpy.data.filepath)\nif ext == ".blend":\n    for rset_context_index in range(len(bpy.context.scene.renderset_contexts)):\n        bpy.context.scene.renderset_context_index = rset_context_index\n        context = bpy.context.scene.renderset_contexts[rset_context_index]\n        if not context.include_in_render_all:\n            continue\n        bpy.ops.wm.save_as_mainfile(filepath=f"{basename}_context{rset_context_index}{ext}")\n'''
    script_path = os.path.join(SCRIPTS_DIR, "render_split_by_context.py")
    with open(script_path, 'w') as f:
        f.write(script_code)
    return script_path

# Run Blender with the generated script
def run_blender(blender_path, blend_file, script_path, done_callback):
    def task():
        with open(LOG_PATH, "w") as log:
            subprocess.run([
                blender_path,
                "--background",
                blend_file,
                "--python",
                script_path
            ], stdout=log, stderr=log)
        done_callback()

    threading.Thread(target=task).start()

# Prompt for Blender executable path
def browse_blender():
    return filedialog.askopenfilename(title="Select Blender.exe", filetypes=[("Blender", "blender.exe")])

# Prompt for .blend file path
def browse_blend():
    return filedialog.askopenfilename(title="Select .blend file", filetypes=[("Blend files", "*.blend")])

# Main GUI logic
def start():
    ensure_dirs()
    config = load_config()
    generate_split_script()

    def on_browse_blender():
        path = browse_blender()
        if path:
            blender_path_var.set(path)

    def on_browse_blend():
        path = browse_blend()
        if path:
            blend_path_var.set(path)

    def on_done():
        progress.stop()
        progress.pack_forget()
        run_button.config(state="normal")
        messagebox.showinfo("Completed", "Split completed successfully.")
        progress.pack_forget()
        run_button.config(state="normal")

    def on_run():
        blender = blender_path_var.get()
        blend = blend_path_var.get()

        if not os.path.isfile(blender):
            messagebox.showerror("Error", "Invalid path to Blender.exe")
            return
        if not os.path.isfile(blend):
            messagebox.showerror("Error", ".blend file not found")
            return

        save_config({"blender_path": blender})
        script_path = os.path.join(SCRIPTS_DIR, "render_split_by_context.py")

        progress.pack(fill="x", padx=10, pady=(0, 10))
        progress.start()
        run_button.config(state="disabled")
        run_blender(blender, blend, script_path, on_done)

    root = tk.Tk()
    root.title("Split Blender Contexts")
    root.geometry("520x260")
    root.configure(bg="#1e1e1e")

    style = ttk.Style()
    style.theme_use("clam")
    style.configure("TLabel", background="#1e1e1e", foreground="#ffffff")
    style.configure("TButton", background="#3c3f41", foreground="#ffffff")
    style.configure("TEntry", fieldbackground="#2e2e2e", foreground="#ffffff")
    style.configure("TProgressbar", troughcolor="#2e2e2e", background="#0078d4", bordercolor="#1e1e1e", lightcolor="#0078d4", darkcolor="#0078d4")

    blender_path_var = tk.StringVar(value=config.get("blender_path", ""))
    blend_path_var = tk.StringVar()

    ttk.Label(root, text="Path to Blender:").pack(anchor="w", padx=10, pady=(10, 0))
    ttk.Entry(root, textvariable=blender_path_var, width=70).pack(padx=10)
    ttk.Button(root, text="Browse", command=on_browse_blender).pack(padx=10, pady=(0, 10))

    ttk.Label(root, text="Blend file:").pack(anchor="w", padx=10)
    ttk.Entry(root, textvariable=blend_path_var, width=70).pack(padx=10)
    ttk.Button(root, text="Browse", command=on_browse_blend).pack(padx=10, pady=(0, 10))

    run_button = ttk.Button(root, text="Split by Contexts", command=on_run)
    run_button.pack(padx=10, pady=(0, 10))

    progress = ttk.Progressbar(root, mode="indeterminate")

    root.mainloop()


if __name__ == "__main__":
    start()
