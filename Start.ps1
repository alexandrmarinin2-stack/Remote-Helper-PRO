# --- САМОПОВЫШЕНИЕ ПРАВ (UAC) ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
# --------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Включаем темный заголовок окна (с проверкой, чтобы не было ошибки при повторном запуске)
if (-not ("DarkTitleBar" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class DarkTitleBar {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
    public static void Apply(IntPtr handle) {
        int useDarkMode = 1;
        DwmSetWindowAttribute(handle, 20, ref useDarkMode, sizeof(int));
        DwmSetWindowAttribute(handle, 19, ref useDarkMode, sizeof(int));
    }
}
"@ -ErrorAction SilentlyContinue
}

# --- ПОДКЛЮЧАЕМ МОДУЛИ ---
. "$PSScriptRoot\Utils.ps1"
. "$PSScriptRoot\Core.ps1"
. "$PSScriptRoot\Actions.ps1"
. "$PSScriptRoot\UI.ps1"

# --- ЗАПУСК ИНТЕРФЕЙСА ---
Show-MainForm