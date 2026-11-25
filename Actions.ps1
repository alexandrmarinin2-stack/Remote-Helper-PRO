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

# НОВАЯ ФУНКЦИЯ 1: Установка обновлений Windows
function Install-RemoteUpdates {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        try {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            # Ищем неустановленные обновления
            $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            
            if ($searchResult.Updates.Count -eq 0) { return "No updates available." }
            
            $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($update in $searchResult.Updates) { $updatesToInstall.Add($update) | Out-Null }
            
            $downloader = $updateSession.CreateUpdateDownloader()
            $downloader.Updates = $updatesToInstall
            $downloader.Download() | Out-Null
            
            $installer = $updateSession.CreateUpdateInstaller()
            $installer.Updates = $updatesToInstall
            $installResult = $installer.Install()
            
            return "Updates installed: $($updatesToInstall.Count). Reboot required: $($installResult.RebootRequired)"
        } catch {
            return "Failed to install updates: $($_.Exception.Message)"
        }
    }
}

# НОВАЯ ФУНКЦИЯ 2: Получение списка процессов (топ по памяти)
function Get-RemoteProcesses {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Get-Process | Sort-Object -Property WorkingSet64 -Descending | 
        Select-Object -First 20 -Property PSComputerName, ProcessName, Id, 
        @{N='RAM(MB)';E={[math]::Round($_.WorkingSet64/1MB,2)}}
    }
}

# НОВАЯ ФУНКЦИЯ 3: Убить процесс
function Stop-RemoteProcess {
    param($Session, $ProcessId, $ProcessName)
    return Invoke-Command -Session $Session -ScriptBlock {
        param($pId, $pName)
        try {
            Stop-Process -Id $pId -Force -ErrorAction Stop
            return "Killed process $pName (ID: $pId)."
        } catch {
            return "Error killing $pName (ID: $pId): $_"
        }
    } -ArgumentList $ProcessId, $ProcessName
}

# НОВАЯ ФУНКЦИЯ 4: Получение критических ошибок из Event Log
function Get-RemoteEventLogs {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 30 -ErrorAction SilentlyContinue | 
        Select-Object PSComputerName, TimeCreated, Id, LevelDisplayName, ProviderName, Message
    }
}