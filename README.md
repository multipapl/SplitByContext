# Blender Renderset Context Splitter (Headless)

This tool automatically splits a `.blend` file into multiple versions — one per active context from the `renderset` add-on. Each output file contains a single camera context and is named accordingly.

---

## How to Run

### 1. EXE version
- No Python required
- Just download the `.exe` or `.zip`, extract, and double-click

### 2. PowerShell version
- Launched via `run_split_tool.bat`
- Python is not required, only Blender
- Logic is handled in `SplitByContext.ps1`

---

## Everything is included in the Releases
- EXE file  
- ZIP archive  
- PowerShell version with `.bat` launcher

---

## Output

Files are saved in the same folder as the original `.blend`:

