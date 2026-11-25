#Requires -RunAsAdministrator

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- ВКЛЮЧАЕМ ТЕМНЫЙ ЗАГОЛОВОК ОКНА (Windows API) ---
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class DarkTitleBar {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
    public static void Apply(IntPtr handle) {
        int useDarkMode = 1;
        DwmSetWindowAttribute(handle, 20, ref useDarkMode, sizeof(int)); // Win 10 20H1+, Win 11
        DwmSetWindowAttribute(handle, 19, ref useDarkMode, sizeof(int)); // Старые Win 10
    }
}
"@ -ErrorAction SilentlyContinue

# ==========================================
# БЛОК 1: ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (UTILS)
# ==========================================
$global:HistoryFile = "$env:LOCALAPPDATA\RemoteHelper\history.json"
$global:PCHistory = @()
$global:InstallerDir = Join-Path $PSScriptRoot "Installers"

function Write-UILog {
    param(
        [System.Windows.Forms.TextBox]$LogBox,
        [string]$Message,
        [string]$TargetPC = "General",
        [System.Drawing.Color]$Color = [System.Drawing.Color]::LightGreen
    )
    $time = Get-Date -Format "HH:mm:ss"
    $logString = "[$time] $Message"

    $LogBox.AppendText("$logString`r`n")
    $LogBox.SelectionStart = $LogBox.Text.Length
    $LogBox.ScrollToCaret()

    $logDir = "C:\Logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    
    if ([string]::IsNullOrWhiteSpace($TargetPC) -or $TargetPC -match '[, ]+') {
        $safeName = "General"
    } else {
        $safeName = $TargetPC -replace '[\\/:*?"<>|]', '_'
    }
    
    $logFile = "$logDir\${safeName}_$(Get-Date -Format 'yyyy-MM-dd').log"
    
    if ($Color -eq [System.Drawing.Color]::Red) {
        $Message | Out-File -FilePath $logFile -Append -Encoding utf8
    } else {
        $logString | Out-File -FilePath $logFile -Append -Encoding utf8
    }

    [System.Windows.Forms.Application]::DoEvents()
}

# ==========================================
# БЛОК 2: СЕТЬ (CORE)
# ==========================================
function Test-TcpPort {
    param([string]$ComputerName, [int]$Port, [int]$TimeoutMs = 1000)
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($ComputerName, $Port, $null, $null)
        $success = $connect.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        
        if ($success) {
            $tcpClient.EndConnect($connect)
            $tcpClient.Close()
            return $true
        }
        $tcpClient.Close()
        return $false
    } catch {
        return $false
    }
}

function Connect-ToRemotePC {
    param([string[]]$TargetPCs)
    
    $validPCs = @()

    foreach ($pc in $TargetPCs) {
        try {
            [System.Net.Dns]::GetHostAddresses($pc) | Out-Null
        } catch {
            Write-UILog -LogBox $global:txtLog -Message "Error: PC '$pc' not found in DNS. Skipping..." -TargetPC $pc -Color ([System.Drawing.Color]::Red)
            continue
        }

        Write-UILog -LogBox $global:txtLog -Message "Checking $pc..." -TargetPC $pc -Color ([System.Drawing.Color]::Yellow)
        
        $isReachable = $false
        $checkReason = ""

        if (Test-Connection -ComputerName $pc -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $isReachable = $true
            $checkReason = "ICMP (Ping)"
        } elseif (Test-TcpPort -ComputerName $pc -Port 5985) {
            $isReachable = $true
            $checkReason = "WinRM Port (TCP 5985)"
        } elseif (Test-TcpPort -ComputerName $pc -Port 445) {
            $isReachable = $true
            $checkReason = "SMB Port (TCP 445)"
        }

        if ($isReachable) {
            Write-UILog -LogBox $global:txtLog -Message "[$pc] Online via $checkReason" -TargetPC $pc -Color ([System.Drawing.Color]::Green)
            $validPCs += $pc
        } else {
            Write-UILog -LogBox $global:txtLog -Message "[$pc] Offline. All ports blocked. Skipping." -TargetPC $pc -Color ([System.Drawing.Color]::Red)
        }
    }

    if ($validPCs.Count -eq 0) {
        throw "No reachable PCs found. Aborting."
    }

    Write-UILog -LogBox $global:txtLog -Message "Creating WinRM sessions for $($validPCs.Count) PC(s)..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
    return New-PSSession -ComputerName $validPCs -ErrorAction Stop
}

function Disconnect-RemotePC {
    param($Session)
    if ($Session) { Remove-PSSession -Session $Session -ErrorAction SilentlyContinue }
}

# ==========================================
# БЛОК 3: ДЕЙСТВИЯ (ACTIONS)
# ==========================================
function Get-RemoteSystemInfo {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        $os = Get-CimInstance Win32_OperatingSystem
        $uptime = (Get-Date) - $os.LastBootUpTime
        "OS: $($os.Caption) | Uptime: $([math]::Round($uptime.TotalDays, 1)) days"
    } | Select-Object PSComputerName, @{N='Info';E={$_}}
}

function Invoke-RemoteCustomCommand {
    param($Session, [string]$Command)
    return Invoke-Command -Session $Session -ScriptBlock { Invoke-Expression $using:Command }
}

function Install-RemoteMsi {
    param($Session, [string]$FilePath)
    $fileName = Split-Path $FilePath -Leaf
    Copy-Item -Path $FilePath -Destination "C:\Windows\Temp\$fileName" -ToSession $Session -Force
    return Invoke-Command -Session $Session -ScriptBlock {
        param($name)
        $p = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i C:\Windows\Temp\$name /qn /norestart" -Wait -PassThru
        return "Installation code: $($p.ExitCode)"
    } -ArgumentList $fileName
}

function Install-RemoteExe {
    param($Session, [string]$FilePath, [string]$Arguments)
    $fileName = Split-Path $FilePath -Leaf
    Copy-Item -Path $FilePath -Destination "C:\Windows\Temp\$fileName" -ToSession $Session -Force
    return Invoke-Command -Session $Session -ScriptBlock {
        param($name, $args)
        $p = Start-Process -FilePath "C:\Windows\Temp\$name" -ArgumentList $args -Wait -PassThru
        return "Installation code: $($p.ExitCode)"
    } -ArgumentList $fileName, $Arguments
}

function Restart-RemotePC {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock { 
        Restart-Computer -Force 
        return "Reboot command sent."
    }
}

function Clear-RemoteTemp {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        "Temp files cleared."
    }
}

function Get-RemoteDiskSpace {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
            "Drive $($_.DeviceID) Free: $([math]::Round($_.FreeSpace/1GB,2)) GB"
        }
    }
}

function Restart-RemoteSpooler {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Restart-Service -Name Spooler -Force -ErrorAction SilentlyContinue
        "Print Spooler restarted."
    }
}

# ==========================================
# БЛОК 4: ИНТЕРФЕЙС И ЛОГИКА (MAIN)
# ==========================================
$global:PSSession = $null

$bgColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
$panelColor = [System.Drawing.Color]::FromArgb(49, 50, 68)
$textColor = [System.Drawing.Color]::FromArgb(205, 214, 244)
$accentColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
$diagColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
$actionColor = [System.Drawing.Color]::FromArgb(166, 227, 161)
$dangerColor = [System.Drawing.Color]::FromArgb(243, 139, 168)

# Окно
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Helper PRO"
$form.Size = New-Object System.Drawing.Size(760, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = $bgColor
$form.ForeColor = $textColor
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\imageres.dll")

# --- ВЕРХНЯЯ ПАНЕЛЬ ---
$lblPC = New-Object System.Windows.Forms.Label
$lblPC.Text = "Target PC(s):"
$lblPC.Location = New-Object System.Drawing.Point(10, 15)
$lblPC.Size = New-Object System.Drawing.Size(75, 20)
$lblPC.ForeColor = $textColor
$form.Controls.Add($lblPC)

$txtPC = New-Object System.Windows.Forms.TextBox
$txtPC.Location = New-Object System.Drawing.Point(85, 12)
$txtPC.Size = New-Object System.Drawing.Size(180, 20)
$txtPC.BackColor = $panelColor
$txtPC.ForeColor = $textColor
$txtPC.BorderStyle = 'FixedSingle'
$txtPC.Text = "PC-01, PC-02"
$txtPC.AutoCompleteMode = 'SuggestAppend'
$txtPC.AutoCompleteSource = 'CustomSource'
$form.Controls.Add($txtPC)

$btnConnect = New-Object System.Windows.Forms.Button
$btnConnect.Text = "Connect"
$btnConnect.Location = New-Object System.Drawing.Point(275, 10)
$btnConnect.Size = New-Object System.Drawing.Size(80, 25)
$btnConnect.BackColor = $panelColor
$btnConnect.ForeColor = [System.Drawing.Color]::LightGreen
$btnConnect.FlatStyle = 'Flat'
$btnConnect.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$form.Controls.Add($btnConnect)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Status: Disconnected"
$lblStatus.Location = New-Object System.Drawing.Point(365, 15)
$lblStatus.Size = New-Object System.Drawing.Size(130, 20)
$lblStatus.ForeColor = [System.Drawing.Color]::Red
$form.Controls.Add($lblStatus)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(630, 12)
$progress.Size = New-Object System.Drawing.Size(100, 20)
$progress.Style = 'Marquee'
$progress.Visible = $false
$form.Controls.Add($progress)

$line = New-Object System.Windows.Forms.Label
$line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$line.Location = New-Object System.Drawing.Point(10, 45)
$line.Size = New-Object System.Drawing.Size(725, 2)
$form.Controls.Add($line)

# ==========================================
# БЛОК КНОПОК И УСТАНОВКИ
# ==========================================

# 1-й ряд (Диагностика - Синий)
$btnSysInfo = New-Object System.Windows.Forms.Button
$btnSysInfo.Text = "System Info"
$btnSysInfo.Location = New-Object System.Drawing.Point(10, 60)
$btnSysInfo.Size = New-Object System.Drawing.Size(135, 30)
$btnSysInfo.BackColor = $diagColor
$btnSysInfo.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnSysInfo.FlatStyle = 'Flat'
$btnSysInfo.FlatAppearance.BorderSize = 0
$btnSysInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnSysInfo.Enabled = $false
$form.Controls.Add($btnSysInfo)

$btnDiskSpace = New-Object System.Windows.Forms.Button
$btnDiskSpace.Text = "Disk Space"
$btnDiskSpace.Location = New-Object System.Drawing.Point(155, 60)
$btnDiskSpace.Size = New-Object System.Drawing.Size(135, 30)
$btnDiskSpace.BackColor = $diagColor
$btnDiskSpace.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnDiskSpace.FlatStyle = 'Flat'
$btnDiskSpace.FlatAppearance.BorderSize = 0
$btnDiskSpace.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnDiskSpace.Enabled = $false
$form.Controls.Add($btnDiskSpace)

$btnSearchApps = New-Object System.Windows.Forms.Button
$btnSearchApps.Text = "Search Apps"
$btnSearchApps.Location = New-Object System.Drawing.Point(300, 60)
$btnSearchApps.Size = New-Object System.Drawing.Size(135, 30)
$btnSearchApps.BackColor = $diagColor
$btnSearchApps.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnSearchApps.FlatStyle = 'Flat'
$btnSearchApps.FlatAppearance.BorderSize = 0
$btnSearchApps.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnSearchApps.Enabled = $false
$form.Controls.Add($btnSearchApps)

$btnRunCmd = New-Object System.Windows.Forms.Button
$btnRunCmd.Text = "Run Command"
$btnRunCmd.Location = New-Object System.Drawing.Point(445, 60)
$btnRunCmd.Size = New-Object System.Drawing.Size(135, 30)
$btnRunCmd.BackColor = $diagColor
$btnRunCmd.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnRunCmd.FlatStyle = 'Flat'
$btnRunCmd.FlatAppearance.BorderSize = 0
$btnRunCmd.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnRunCmd.Enabled = $false
$form.Controls.Add($btnRunCmd)

# 2-й ряд (Установка)
$lblInstall = New-Object System.Windows.Forms.Label
$lblInstall.Text = "Installer:"
$lblInstall.Location = New-Object System.Drawing.Point(10, 108)
$lblInstall.Size = New-Object System.Drawing.Size(60, 20)
$lblInstall.ForeColor = $textColor
$form.Controls.Add($lblInstall)

$cmbInstallers = New-Object System.Windows.Forms.ComboBox
$cmbInstallers.Location = New-Object System.Drawing.Point(75, 105)
$cmbInstallers.Size = New-Object System.Drawing.Size(350, 25)
$cmbInstallers.BackColor = $panelColor
$cmbInstallers.ForeColor = $textColor
$cmbInstallers.FlatStyle = 'Flat'
$cmbInstallers.DropDownStyle = 'DropDownList'
$form.Controls.Add($cmbInstallers)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Install"
$btnInstall.Location = New-Object System.Drawing.Point(435, 100)
$btnInstall.Size = New-Object System.Drawing.Size(100, 30)
$btnInstall.BackColor = $actionColor
$btnInstall.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnInstall.FlatStyle = 'Flat'
$btnInstall.FlatAppearance.BorderSize = 0
$btnInstall.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnInstall.Enabled = $false
$form.Controls.Add($btnInstall)

$btnOpenInstallers = New-Object System.Windows.Forms.Button
$btnOpenInstallers.Text = "Open Folder"
$btnOpenInstallers.Location = New-Object System.Drawing.Point(545, 100)
$btnOpenInstallers.Size = New-Object System.Drawing.Size(100, 30)
$btnOpenInstallers.BackColor = $panelColor
$btnOpenInstallers.ForeColor = $textColor
$btnOpenInstallers.FlatStyle = 'Flat'
$btnOpenInstallers.FlatAppearance.BorderSize = 0
$btnOpenInstallers.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnOpenInstallers)

# Кнопка обновления списка (ТЕПЕРЬ КВАДРАТНАЯ, ТОЛЬКО ИКОНКА)
$btnRefreshList = New-Object System.Windows.Forms.Button
$btnRefreshList.Text = "🔄"
$btnRefreshList.Location = New-Object System.Drawing.Point(655, 100)
$btnRefreshList.Size = New-Object System.Drawing.Size(30, 30) # Сделали квадратной 30x30
$btnRefreshList.BackColor = $panelColor
$btnRefreshList.ForeColor = $textColor
$btnRefreshList.FlatStyle = 'Flat'
$btnRefreshList.FlatAppearance.BorderSize = 0
$btnRefreshList.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 14, [System.Drawing.FontStyle]::Bold) # Увеличили шрифт
$form.Controls.Add($btnRefreshList)

# 3-й ряд (Действия - Зеленый и Красный)
$btnClearTemp = New-Object System.Windows.Forms.Button
$btnClearTemp.Text = "Clear Temp"
$btnClearTemp.Location = New-Object System.Drawing.Point(10, 140)
$btnClearTemp.Size = New-Object System.Drawing.Size(135, 30)
$btnClearTemp.BackColor = $actionColor
$btnClearTemp.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnClearTemp.FlatStyle = 'Flat'
$btnClearTemp.FlatAppearance.BorderSize = 0
$btnClearTemp.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnClearTemp.Enabled = $false
$form.Controls.Add($btnClearTemp)

$btnFixSpooler = New-Object System.Windows.Forms.Button
$btnFixSpooler.Text = "Fix Spooler"
$btnFixSpooler.Location = New-Object System.Drawing.Point(155, 140)
$btnFixSpooler.Size = New-Object System.Drawing.Size(135, 30)
$btnFixSpooler.BackColor = $actionColor
$btnFixSpooler.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnFixSpooler.FlatStyle = 'Flat'
$btnFixSpooler.FlatAppearance.BorderSize = 0
$btnFixSpooler.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnFixSpooler.Enabled = $false
$form.Controls.Add($btnFixSpooler)

$btnReboot = New-Object System.Windows.Forms.Button
$btnReboot.Text = "Reboot PC"
$btnReboot.Location = New-Object System.Drawing.Point(590, 140)
$btnReboot.Size = New-Object System.Drawing.Size(135, 30)
$btnReboot.BackColor = $dangerColor
$btnReboot.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$btnReboot.FlatStyle = 'Flat'
$btnReboot.FlatAppearance.BorderSize = 0
$btnReboot.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnReboot.Enabled = $false
$form.Controls.Add($btnReboot)

# Массив для быстрого включения/выключения кнопок
$allActionButtons = @($btnSysInfo, $btnDiskSpace, $btnSearchApps, $btnRunCmd, $btnInstall, $btnClearTemp, $btnFixSpooler, $btnReboot)

# --- ОКНО ЛОГА ---
$global:txtLog = New-Object System.Windows.Forms.TextBox
$global:txtLog.Location = New-Object System.Drawing.Point(10, 180)
$global:txtLog.Size = New-Object System.Drawing.Size(725, 330)
$global:txtLog.Multiline = $true
$global:txtLog.ScrollBars = "Vertical"
$global:txtLog.ReadOnly = $true
$global:txtLog.BackColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
$global:txtLog.ForeColor = $accentColor
$global:txtLog.Font = New-Object System.Drawing.Font("Consolas", 10)
$global:txtLog.BorderStyle = 'None'
$form.Controls.Add($global:txtLog)

# --- КНОПКИ УПРАВЛЕНИЯ ЛОГОМ ---
$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear Log"
$btnClear.Location = New-Object System.Drawing.Point(10, 520)
$btnClear.Size = New-Object System.Drawing.Size(100, 25)
$btnClear.BackColor = $panelColor
$btnClear.ForeColor = $dangerColor
$btnClear.FlatStyle = 'Flat'
$btnClear.FlatAppearance.BorderSize = 0
$btnClear.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnClear)

$btnOpenLogs = New-Object System.Windows.Forms.Button
$btnOpenLogs.Text = "Open Logs" 
$btnOpenLogs.Location = New-Object System.Drawing.Point(120, 520)
$btnOpenLogs.Size = New-Object System.Drawing.Size(100, 25)
$btnOpenLogs.BackColor = $panelColor
$btnOpenLogs.ForeColor = $diagColor 
$btnOpenLogs.FlatStyle = 'Flat'
$btnOpenLogs.FlatAppearance.BorderSize = 0
$btnOpenLogs.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnOpenLogs)


# --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ UI ---
function Refresh-InstallerList {
    $cmbInstallers.Items.Clear()
    
    if (-not (Test-Path $global:InstallerDir)) {
        New-Item -ItemType Directory -Path $global:InstallerDir -Force | Out-Null
    }

    $files = Get-ChildItem -Path $global:InstallerDir -Include *.msi, *.exe -File -ErrorAction SilentlyContinue
    if ($files.Count -gt 0) {
        foreach ($file in $files) {
            [void]$cmbInstallers.Items.Add($file.Name)
        }
        $cmbInstallers.SelectedIndex = 0
    } else {
        [void]$cmbInstallers.Items.Add("-- No installers found --")
        $cmbInstallers.SelectedIndex = 0
    }
}

function Execute-AsyncAction {
    param([ScriptBlock]$ActionCode)
    $progress.Visible = $true
    $form.Refresh()
    try {
        & $ActionCode
    } catch {
        Write-UILog -LogBox $global:txtLog -Message "ERROR: $($_.Exception.Message)" -TargetPC "General" -Color ([System.Drawing.Color]::Red)
        Write-UILog -LogBox $global:txtLog -Message "$($_.Exception.ToString())" -TargetPC "General" -Color ([System.Drawing.Color]::Red)
    } finally {
        $progress.Visible = $false
        $form.Refresh()
    }
}

# --- ОБРАБОТЧИКИ СОБЫТИЙ ---
$btnOpenInstallers.Add_Click({
    if (-not (Test-Path $global:InstallerDir)) {
        New-Item -ItemType Directory -Path $global:InstallerDir -Force | Out-Null
    }
    Start-Process explorer.exe -ArgumentList $global:InstallerDir
})

$btnRefreshList.Add_Click({
    Refresh-InstallerList
    Write-UILog -LogBox $global:txtLog -Message "Installer list refreshed." -TargetPC "General" -Color ([System.Drawing.Color]::Gray)
})

$btnConnect.Add_Click({
    $rawPCs = $txtPC.Text.Trim()
    if (-not $rawPCs) { return }

    $global:PCHistory = @($rawPCs) + ($global:PCHistory | Where-Object { $_ -ne $rawPCs })
    if ($global:PCHistory.Count -gt 10) { $global:PCHistory = $global:PCHistory[0..9] }
    $dir = Split-Path $global:HistoryFile -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $global:PCHistory | ConvertTo-Json | Out-File $global:HistoryFile -Encoding utf8
    
    $txtPC.AutoCompleteCustomSource.Clear()
    $txtPC.AutoCompleteCustomSource.AddRange($global:PCHistory)
    
    $pcList = $rawPCs -split '[, ]+' | Where-Object { $_ -ne "" }

    Execute-AsyncAction {
        Write-UILog -LogBox $global:txtLog -Message "Connecting to $($pcList.Count) PC(s)..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
        $lblStatus.Text = "Status: Connecting..."
        $lblStatus.ForeColor = [System.Drawing.Color]::Orange
        $form.Refresh()
        try {
            $global:PSSession = Connect-ToRemotePC -TargetPCs $pcList
            $lblStatus.Text = "Status: Connected ($($pcList.Count))"
            $lblStatus.ForeColor = [System.Drawing.Color]::Green
            Write-UILog -LogBox $global:txtLog -Message "Successfully connected!" -TargetPC "General" -Color ([System.Drawing.Color]::Green)
            foreach ($b in $allActionButtons) { $b.Enabled = $true }
        } catch {
            $lblStatus.Text = "Status: Error"
            $lblStatus.ForeColor = [System.Drawing.Color]::Red
            Write-UILog -LogBox $global:txtLog -Message "Error: $($_.Exception.Message)" -TargetPC "General" -Color ([System.Drawing.Color]::Red)
            foreach ($b in $allActionButtons) { $b.Enabled = $false }
        }
    }
})

$btnInstall.Add_Click({
    $selectedItem = $cmbInstallers.SelectedItem.ToString()
    if ($selectedItem -match "No installers found") {
        [System.Windows.Forms.MessageBox]::Show("Please put .msi or .exe files into the Installers folder first.", "No Files", "OK", "Warning")
        return
    }

    $filePath = Join-Path $global:InstallerDir $selectedItem
    $extension = [System.IO.Path]::GetExtension($filePath).ToLower()

    $defaultArgs = if ($extension -eq ".msi") { "/qn /norestart" } else { "/S" }
    $silentArgs = [Microsoft.VisualBasic.Interaction]::InputBox("Enter silent arguments for ${selectedItem}:", "Silent Args", $defaultArgs)
    
    if ($silentArgs -eq $null) { return }

    Execute-AsyncAction {
        Write-UILog -LogBox $global:txtLog -Message "Installing $selectedItem..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
        
        if ($extension -eq ".msi") {
            $res = Install-RemoteMsi -Session $global:PSSession -FilePath $filePath
        } else {
            $res = Install-RemoteExe -Session $global:PSSession -FilePath $filePath -Arguments $silentArgs
        }
        
        $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) }
    }
})

$btnSysInfo.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Fetching info..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Get-RemoteSystemInfo -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.Info)" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Cyan) } } })

$btnRunCmd.Add_Click({
    $cmd = [Microsoft.VisualBasic.Interaction]::InputBox("Enter command:", "Run", "Get-Service")
    if ($cmd) {
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Executing: $cmd" -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $res = Invoke-RemoteCustomCommand -Session $global:PSSession -Command $cmd
            $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::White) }
        }
    }
})

$btnReboot.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show("Reboot selected PC(s)?", "Confirm", "YesNo", "Question")
    if ($confirm -eq "Yes") {
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Sending reboot..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $res = Restart-RemotePC -Session $global:PSSession
            $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) }
        }
    }
})

$btnClearTemp.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Clearing Temp..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Clear-RemoteTemp -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })
$btnDiskSpace.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Checking Disk Space..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Get-RemoteDiskSpace -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Cyan) } } })
$btnFixSpooler.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Restarting Spooler..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Restart-RemoteSpooler -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })

$btnSearchApps.Add_Click({
    Execute-AsyncAction {
        Write-UILog -LogBox $global:txtLog -Message "Fetching all installed apps..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
        
        $apps = Invoke-Command -Session $global:PSSession -ScriptBlock {
            Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
            Where-Object { $_.DisplayName -ne $null -and $_.DisplayName -ne "" } | 
            Select-Object PSComputerName, DisplayName, DisplayVersion
        }

        $formApps = New-Object System.Windows.Forms.Form
        $formApps.Text = "Installed Applications"
        $formApps.Size = New-Object System.Drawing.Size(800, 500)
        $formApps.StartPosition = "CenterParent"
        $formApps.BackColor = $bgColor
        $formApps.Icon = $form.Icon

        $lblSearch = New-Object System.Windows.Forms.Label
        $lblSearch.Text = "Search:"
        $lblSearch.Location = New-Object System.Drawing.Point(10, 15)
        $lblSearch.ForeColor = $textColor
        $formApps.Controls.Add($lblSearch)

        $txtSearch = New-Object System.Windows.Forms.TextBox
        $txtSearch.Location = New-Object System.Drawing.Point(60, 12)
        $txtSearch.Size = New-Object System.Drawing.Size(710, 20)
        $txtSearch.BackColor = $panelColor
        $txtSearch.ForeColor = $textColor
        $formApps.Controls.Add($txtSearch)

        $grid = New-Object System.Windows.Forms.DataGridView
        $grid.Location = New-Object System.Drawing.Point(10, 40)
        $grid.Size = New-Object System.Drawing.Size(760, 400)
        $grid.BackgroundColor = $bgColor
        $grid.GridColor = $panelColor
        $grid.DefaultCellStyle.BackColor = $bgColor
        $grid.DefaultCellStyle.ForeColor = $textColor
        $grid.DefaultCellStyle.SelectionBackColor = $accentColor
        $grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::Black
        $grid.AutoSizeColumnsMode = 'Fill'
        $grid.AllowUserToAddRows = $false
        $grid.ReadOnly = $true
        $grid.DataSource = [System.Collections.ArrayList]@($apps)
        $formApps.Controls.Add($grid)

        $txtSearch.Add_TextChanged({
            $search = $txtSearch.Text
            $filtered = $apps | Where-Object { 
                $_.DisplayName -like "*$search*" -or 
                $_.PSComputerName -like "*$search*" 
            }
            $grid.DataSource = [System.Collections.ArrayList]@($filtered)
        })

        $formApps.Add_Shown({ [DarkTitleBar]::Apply($formApps.Handle) })
        $formApps.ShowDialog()
        $formApps.Dispose()
    }
})

$btnClear.Add_Click({ $global:txtLog.Clear() })

$btnOpenLogs.Add_Click({
    $logDir = "C:\Logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    Start-Process explorer.exe -ArgumentList $logDir
})

$form.Add_Shown({ 
    [DarkTitleBar]::Apply($form.Handle)
    
    if (Test-Path $global:HistoryFile) {
        try {
            $historyData = Get-Content $global:HistoryFile -Raw | ConvertFrom-Json
            $global:PCHistory = @($historyData)
        } catch {}
    }
    $txtPC.AutoCompleteCustomSource.Clear()
    if ($global:PCHistory.Count -gt 0) {
        $txtPC.AutoCompleteCustomSource.AddRange($global:PCHistory)
    }

    Refresh-InstallerList

    Write-UILog -LogBox $global:txtLog -Message "Program initialized. Drop .exe/.msi into the Installers folder." -TargetPC "General" -Color ([System.Drawing.Color]::Gray)
    $txtPC.Focus() 
})
[void]$form.ShowDialog()

Disconnect-RemotePC -Session $global:PSSession