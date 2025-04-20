Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === Шляхи до скрипта і логів ===
$ConfigPath = "C:\blender_headless_tools\config.json"
$ScriptsDir = "C:\blender_headless_tools\scripts"
$LogPath = "C:\blender_headless_tools\log.txt"
$ScriptPath = Join-Path $ScriptsDir "render_split_by_context.py"

# === Гарантоване створення директорій
New-Item -ItemType Directory -Force -Path $ScriptsDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $ConfigPath) | Out-Null

# === Генеруємо Blender скрипт ===
$pyScript = @'
import bpy
import os

print("Starting context split...")

basename, ext = os.path.splitext(bpy.data.filepath)
if ext == ".blend":
    for index in range(len(bpy.context.scene.renderset_contexts)):
        bpy.context.scene.renderset_context_index = index
        context = bpy.context.scene.renderset_contexts[index]

        if not context.include_in_render_all:
            continue

        active_camera = bpy.context.scene.camera
        name = active_camera.name.strip().replace(" ", "_").replace("/", "_") if active_camera else f"Context{index}"
        outpath = f"{basename}_{name}{ext}"
        print(f"Saving: {outpath}")
        bpy.ops.wm.save_as_mainfile(filepath=outpath)

print("Context split completed.")
'@
$pyScript | Set-Content -Encoding UTF8 $ScriptPath

# === Конфіг — збереження та завантаження
function Save-Config($blenderPath) {
    $config = @{ blender_path = $blenderPath }
    $config | ConvertTo-Json | Set-Content -Encoding UTF8 $ConfigPath
}
function Load-Config {
    if (Test-Path $ConfigPath) {
        return Get-Content $ConfigPath | ConvertFrom-Json
    }
    return @{}
}
$config = Load-Config

# === UI ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Split Blender Contexts"
$form.Size = New-Object System.Drawing.Size(500,200)
$form.StartPosition = "CenterScreen"

# Blender Path
$lblBlender = New-Object System.Windows.Forms.Label
$lblBlender.Text = "Path to Blender:"
$lblBlender.Location = New-Object System.Drawing.Point(10,10)
$form.Controls.Add($lblBlender)

$txtBlender = New-Object System.Windows.Forms.TextBox
$txtBlender.Size = New-Object System.Drawing.Size(360,20)
$txtBlender.Location = New-Object System.Drawing.Point(10,30)
$txtBlender.Text = $config.blender_path
$form.Controls.Add($txtBlender)

$btnBlender = New-Object System.Windows.Forms.Button
$btnBlender.Text = "Browse"
$btnBlender.Location = New-Object System.Drawing.Point(380,28)
$btnBlender.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "Blender Executable|blender.exe"
    if ($dlg.ShowDialog() -eq "OK") {
        $txtBlender.Text = $dlg.FileName
    }
})
$form.Controls.Add($btnBlender)

# Blend File
$lblBlend = New-Object System.Windows.Forms.Label
$lblBlend.Text = "Blend file:"
$lblBlend.Location = New-Object System.Drawing.Point(10,60)
$form.Controls.Add($lblBlend)

$txtBlend = New-Object System.Windows.Forms.TextBox
$txtBlend.Size = New-Object System.Drawing.Size(360,20)
$txtBlend.Location = New-Object System.Drawing.Point(10,80)
$form.Controls.Add($txtBlend)

$btnBlend = New-Object System.Windows.Forms.Button
$btnBlend.Text = "Browse"
$btnBlend.Location = New-Object System.Drawing.Point(380,78)
$btnBlend.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "Blend Files|*.blend"
    if ($dlg.ShowDialog() -eq "OK") {
        $txtBlend.Text = $dlg.FileName
    }
})
$form.Controls.Add($btnBlend)

# RUN Button
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Split"
$btnRun.Size = New-Object System.Drawing.Size(80,30)
$btnRun.Location = New-Object System.Drawing.Point(200,120)
$btnRun.Add_Click({
    $blender = $txtBlender.Text
    $blend = $txtBlend.Text

    if (!(Test-Path $blender)) {
        [System.Windows.Forms.MessageBox]::Show("Invalid path to blender.exe")
        return
    }
    if (!(Test-Path $blend)) {
        [System.Windows.Forms.MessageBox]::Show("Blend file not found")
        return
    }

    Save-Config $blender

    $cmd = "`"$blender`" --background `"$blend`" --python `"$ScriptPath`" > `"$LogPath`" 2>&1"
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$cmd`"" -NoNewWindow -Wait

    [System.Windows.Forms.MessageBox]::Show("Done!", "Split Completed")
})
$form.Controls.Add($btnRun)

# Show Form
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
