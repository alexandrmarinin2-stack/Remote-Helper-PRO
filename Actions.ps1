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