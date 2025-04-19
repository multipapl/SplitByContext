# Blender Renderset Context Splitter (Headless)

A small, user-friendly Windows utility that automates the splitting of a `.blend` file into multiple files — one for each enabled render context — using the [polygoniq renderset](https://docs.polygoniq.com/renderset/2.0.1/advanced_topics/headless_rendering/) add-on in headless mode.

---

## 🔧 What It Does

- Prompts the user to select:
  - Path to `blender.exe`
  - A `.blend` file containing renderset contexts
- Generates a Python script that:
  - Loops through all `renderset_contexts` marked with `include_in_render_all`
  - Activates each context sequentially
  - Saves a new `.blend` file for each context
  - Uses the name of the active camera in each context to name the output files
- Launches Blender in `--background` mode to perform the split
- Shows a simple GUI with a progress bar and completion message
- Stores logs and generated scripts in:
  ```
  C:/blender_headless_tools/
  ```

---

## 🖥 How to Run

The tool is available as a ready-to-use `.exe` file in the [Releases](https://github.com/multipapl/SplitByContext/releases/tag/release) section.

⚠️ Note: Windows Defender or other antivirus software may block or warn about the `.exe` file because it is unsigned and newly created.

To avoid this issue, download the `.zip` archive instead. Extract it and run the `.exe` inside.

No installation required — just download and double-click the executable.

Run the compiled `.exe` (e.g. `BlenderSplit_v1.0.exe`) by double-clicking it. No installation required.

---

## 📁 Output

The resulting `.blend` files will be saved next to the original file:

```
project_Camera1.blend
project_Camera2.blend
project_Context3.blend  ← fallback if no active camera
```

---

## 📌 Requirements

- Windows OS
- Blender 4.x or newer
- [polygoniq renderset](https://superhivemarket.com/products/render-manager-addon-renderset) add-on installed and configured

---

This tool does **not** perform rendering — it only prepares `.blend` files for batch rendering workflows.
