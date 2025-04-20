# Blender Renderset Context Splitter (PowerShell Edition)

This minimal tool splits a `.blend` file into multiple versions using active camera contexts from the `renderset` add-on. Each output file contains one context and is named after the assigned camera.

---

## How to Use

1. Double-click `run_split_tool.bat`  
2. Select your Blender executable and a `.blend` file  
3. The tool runs Blender in background and saves one file per context

---

## Included

- `SplitByContext.ps1` – main logic and GUI
- `run_split_tool.bat` – silent launcher (no console)

No installation, Python, or packaging needed.

---

## Output Example

