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
        return "Код установки: $($p.ExitCode)"
    } -ArgumentList $fileName
}

function Install-RemoteExe {
    param($Session, [string]$FilePath, [string]$Arguments)
    $fileName = Split-Path $FilePath -Leaf
    Copy-Item -Path $FilePath -Destination "C:\Windows\Temp\$fileName" -ToSession $Session -Force
    return Invoke-Command -Session $Session -ScriptBlock {
        param($name, $args)
        $p = Start-Process -FilePath "C:\Windows\Temp\$name" -ArgumentList $args -Wait -PassThru
        return "Код установки: $($p.ExitCode)"
    } -ArgumentList $fileName, $Arguments
}

function Restart-RemotePC {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock { Restart-Computer -Force; return "Команда перезагрузки отправлена." }
}

function Clear-RemoteTemp {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        "Временные файлы очищены."
    }
}

function Get-RemoteDiskSpace {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
            "Диск $($_.DeviceID) Свободно: $([math]::Round($_.FreeSpace/1GB,2)) ГБ из $([math]::Round($_.Size/1GB,2)) ГБ"
        }
    }
}

function Restart-RemoteSpooler {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Restart-Service -Name Spooler -Force -ErrorAction SilentlyContinue
        "Служба печати перезапущена."
    }
}

function Install-RemoteUpdates {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        try {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            
            if ($searchResult.Updates.Count -eq 0) { return "Обновлений нет." }
            
            $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($update in $searchResult.Updates) { $updatesToInstall.Add($update) | Out-Null }
            
            $downloader = $updateSession.CreateUpdateDownloader()
            $downloader.Updates = $updatesToInstall
            $downloader.Download() | Out-Null
            
            $installer = $updateSession.CreateUpdateInstaller()
            $installer.Updates = $updatesToInstall
            $installResult = $installer.Install()
            
            return "Установлено обновлений: $($updatesToInstall.Count). Требуется перезагрузка: $($installResult.RebootRequired)"
        } catch {
            return "Ошибка установки обновлений: $($_.Exception.Message)"
        }
    }
}

function Get-RemoteProcesses {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Get-Process | Sort-Object -Property WorkingSet64 -Descending | 
        Select-Object -First 20 -Property PSComputerName, ProcessName, Id, 
        @{N='ОЗУ (МБ)';E={[math]::Round($_.WorkingSet64/1MB,2)}}
    }
}

function Stop-RemoteProcess {
    param($Session, $ProcessId, $ProcessName)
    return Invoke-Command -Session $Session -ScriptBlock {
        param($pId, $pName)
        try {
            Stop-Process -Id $pId -Force -ErrorAction Stop
            return "Процесс $pName (ID: $pId) завершен."
        } catch {
            return "Ошибка завершения $pName (ID: $pId): $_"
        }
    } -ArgumentList $ProcessId, $ProcessName
}

function Get-RemoteEventLogs {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 30 -ErrorAction SilentlyContinue | 
        Select-Object PSComputerName, TimeCreated, Id, LevelDisplayName, ProviderName, Message
    }
}

function Find-RemoteFolder {
    param($Session, [string]$SearchQuery)
    return Invoke-Command -Session $Session -ScriptBlock {
        param($query)
        if (Test-Path $query) { 
            return [PSCustomObject]@{ PC = $env:COMPUTERNAME; Status = "Found"; Path = (Resolve-Path $query).Path } 
        }
        $searchPaths = @("C:\Program Files", "C:\Program Files (x86)", "C:\ProgramData", "C:\Users\Public")
        $results = @()
        foreach ($path in $searchPaths) {
            if (Test-Path $path) {
                $found = Get-ChildItem -Path $path -Filter "*$query*" -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
                if ($found) { $results += $found }
            }
        }
        if ($results.Count -gt 0) {
            return $results | Select-Object -First 5 | ForEach-Object { [PSCustomObject]@{ PC = $env:COMPUTERNAME; Status = "Found"; Path = $_ } }
        } else {
            return [PSCustomObject]@{ PC = $env:COMPUTERNAME; Status = "NotFound"; Path = "Не найдено." }
        }
    } -ArgumentList $SearchQuery
}

# ==========================================
# НОВЫЕ ФУНКЦИИ (Вкладка "Продвинутые")
# ==========================================

function Get-RemoteSessions {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        (quser) 2>$null | ForEach-Object {
            $parts = $_ -split '\s+'
            if ($parts[0] -ne 'USERNAME') {
                [PSCustomObject]@{
                    Пользователь = $parts[0]
                    Сессия = $parts[1]
                    ID = $parts[2]
                    Статус = $parts[3]
                }
            }
        }
    }
}

function Stop-RemoteSession {
    param($Session, $SessionId)
    return Invoke-Command -Session $Session -ScriptBlock {
        param($sId)
        logoff $sId 2>$null
        return "Команда выхода отправлена для сессии ID: $sId"
    } -ArgumentList $SessionId
}

function Get-RemoteServices {
    param($Session, [string]$Filter)
    return Invoke-Command -Session $Session -ScriptBlock {
        param($flt)
        Get-Service | Where-Object { $_.DisplayName -like "*$flt*" -or $_.Name -like "*$flt*" } | 
        Select-Object PSComputerName, Status, Name, DisplayName
    } -ArgumentList $Filter
}

function Restart-RemoteService {
    param($Session, $ServiceName)
    return Invoke-Command -Session $Session -ScriptBlock {
        param($sName)
        try {
            Restart-Service -Name $sName -Force -ErrorAction Stop
            return "Служба $sName перезапущена."
        } catch {
            return "Ошибка перезапуска $sName : $_"
        }
    } -ArgumentList $ServiceName
}

function Clear-RemoteDNS {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        ipconfig /flushdns | Out-Null
        return "Кэш DNS успешно очищен."
    }
}

function Get-RemoteOpenPorts {
    param($Session)
    return Invoke-Command -Session $Session -ScriptBlock {
        Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | 
        Select-Object PSComputerName, LocalAddress, LocalPort, OwningProcess | 
        Sort-Object LocalPort
    }
}

function Remove-RemoteItem {
    param($Session, [string]$Path)
    return Invoke-Command -Session $Session -ScriptBlock {
        param($p)
        try {
            if (Test-Path $p) {
                Remove-Item -Path $p -Recurse -Force -ErrorAction Stop
                return "Успешно удалено: $p"
            } else {
                return "Ошибка: Путь не существует ($p)"
            }
        } catch {
            return "Ошибка удаления $p : $_"
        }
    } -ArgumentList $Path
}