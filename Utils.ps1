# --- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ---
$global:HistoryFile = "$env:LOCALAPPDATA\RemoteHelper\history.json"
$global:PCHistory = @()
$global:InstallerDir = Join-Path $PSScriptRoot "Installers"
$global:PSSession = $null

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

function Load-PCHistory {
    if (Test-Path $global:HistoryFile) {
        try {
            $historyData = Get-Content $global:HistoryFile -Raw | ConvertFrom-Json
            $global:PCHistory = @($historyData)
        } catch {}
    }
}

function Add-PCHistory {
    param([string]$PCString)
    if ([string]::IsNullOrWhiteSpace($PCString)) { return }

    $global:PCHistory = @($PCString) + ($global:PCHistory | Where-Object { $_ -ne $PCString })
    if ($global:PCHistory.Count -gt 10) { $global:PCHistory = $global:PCHistory[0..9] }
    
    $dir = Split-Path $global:HistoryFile -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $global:PCHistory | ConvertTo-Json | Out-File $global:HistoryFile -Encoding utf8
}
# ... (ваш старый код Utils.ps1) ...

# --- УПРАВЛЕНИЕ КЛЮЧАМИ УСТАНОВКИ ---
$global:InstallerKeysFile = "$env:LOCALAPPDATA\RemoteHelper\installer_keys.json"
$global:InstallerKeys = @{}

function Load-InstallerKeys {
    if (Test-Path $global:InstallerKeysFile) {
        try {
            $json = Get-Content $global:InstallerKeysFile -Raw | ConvertFrom-Json
            $json.PSObject.Properties | ForEach-Object { $global:InstallerKeys[$_.Name] = $_.Value }
        } catch {}
    }
}

function Save-InstallerKeys {
    $dir = Split-Path $global:InstallerKeysFile -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $global:InstallerKeys | ConvertTo-Json | Out-File $global:InstallerKeysFile -Encoding utf8
}