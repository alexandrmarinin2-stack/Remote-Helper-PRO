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
    } catch { return $false }
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
            $isReachable = $true; $checkReason = "ICMP (Ping)"
        } elseif (Test-TcpPort -ComputerName $pc -Port 5985) {
            $isReachable = $true; $checkReason = "WinRM Port (TCP 5985)"
        } elseif (Test-TcpPort -ComputerName $pc -Port 445) {
            $isReachable = $true; $checkReason = "SMB Port (TCP 445)"
        }

        if ($isReachable) {
            Write-UILog -LogBox $global:txtLog -Message "[$pc] Online via $checkReason" -TargetPC $pc -Color ([System.Drawing.Color]::Green)
            $validPCs += $pc
        } else {
            Write-UILog -LogBox $global:txtLog -Message "[$pc] Offline. All ports blocked. Skipping." -TargetPC $pc -Color ([System.Drawing.Color]::Red)
        }
    }

    if ($validPCs.Count -eq 0) { throw "No reachable PCs found. Aborting." }

    Write-UILog -LogBox $global:txtLog -Message "Creating WinRM sessions for $($validPCs.Count) PC(s)..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
    return New-PSSession -ComputerName $validPCs -ErrorAction Stop
}

function Disconnect-RemotePC {
    param($Session)
    if ($Session) { Remove-PSSession -Session $Session -ErrorAction SilentlyContinue }
}