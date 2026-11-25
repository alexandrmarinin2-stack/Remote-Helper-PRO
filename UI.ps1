function Show-MainForm {
    $bgColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
    $panelColor = [System.Drawing.Color]::FromArgb(49, 50, 68)
    $textColor = [System.Drawing.Color]::FromArgb(205, 214, 244)
    $accentColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
    $diagColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
    $actionColor = [System.Drawing.Color]::FromArgb(166, 227, 161)
    $dangerColor = [System.Drawing.Color]::FromArgb(243, 139, 168)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Remote Helper PRO"
    $form.Size = New-Object System.Drawing.Size(760, 680)
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

    $txtPC = New-Object System.Windows.Forms.ComboBox
    $txtPC.Location = New-Object System.Drawing.Point(85, 12)
    $txtPC.Size = New-Object System.Drawing.Size(180, 20)
    $txtPC.BackColor = $panelColor
    $txtPC.ForeColor = $textColor
    $txtPC.FlatStyle = 'Flat'
    $txtPC.DropDownStyle = 'DropDown' 
    $txtPC.AutoCompleteMode = 'SuggestAppend'
    $txtPC.AutoCompleteSource = 'ListItems'
    $txtPC.Add_Click({ $txtPC.DroppedDown = $true })
    $form.Controls.Add($txtPC)

    $btnConnect = New-Object System.Windows.Forms.Button
    $btnConnect.Text = "Connect"
    $btnConnect.Location = New-Object System.Drawing.Point(275, 10)
    $btnConnect.Size = New-Object System.Drawing.Size(80, 25)
    $btnConnect.BackColor = $panelColor
    $btnConnect.ForeColor = [System.Drawing.Color]::LightGreen
    $btnConnect.FlatStyle = 'Flat'
    $btnConnect.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
    $btnConnect.TabStop = $false
    $form.Controls.Add($btnConnect)

    $txtPC.Add_KeyDown({
        if ($_.KeyCode -eq 'Enter') { 
            $_.SuppressKeyPress = $true
            $btnConnect.PerformClick() 
        }
    })

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

    # 1-й ряд (Диагностика)
    $btnSysInfo = New-Object System.Windows.Forms.Button
    $btnSysInfo.Text = "System Info"
    $btnSysInfo.Location = New-Object System.Drawing.Point(10, 60)
    $btnSysInfo.Size = New-Object System.Drawing.Size(135, 30)
    $btnSysInfo.BackColor = $diagColor; $btnSysInfo.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnSysInfo.FlatStyle = 'Flat'; $btnSysInfo.FlatAppearance.BorderSize = 0
    $btnSysInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnSysInfo.Enabled = $false; $btnSysInfo.TabStop = $false
    $form.Controls.Add($btnSysInfo)

    $btnDiskSpace = New-Object System.Windows.Forms.Button
    $btnDiskSpace.Text = "Disk Space"
    $btnDiskSpace.Location = New-Object System.Drawing.Point(155, 60)
    $btnDiskSpace.Size = New-Object System.Drawing.Size(135, 30)
    $btnDiskSpace.BackColor = $diagColor; $btnDiskSpace.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnDiskSpace.FlatStyle = 'Flat'; $btnDiskSpace.FlatAppearance.BorderSize = 0
    $btnDiskSpace.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnDiskSpace.Enabled = $false; $btnDiskSpace.TabStop = $false
    $form.Controls.Add($btnDiskSpace)

    $btnSearchApps = New-Object System.Windows.Forms.Button
    $btnSearchApps.Text = "Search Apps"
    $btnSearchApps.Location = New-Object System.Drawing.Point(300, 60)
    $btnSearchApps.Size = New-Object System.Drawing.Size(135, 30)
    $btnSearchApps.BackColor = $diagColor; $btnSearchApps.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnSearchApps.FlatStyle = 'Flat'; $btnSearchApps.FlatAppearance.BorderSize = 0
    $btnSearchApps.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnSearchApps.Enabled = $false; $btnSearchApps.TabStop = $false
    $form.Controls.Add($btnSearchApps)

    $btnRunCmd = New-Object System.Windows.Forms.Button
    $btnRunCmd.Text = "Run Command"
    $btnRunCmd.Location = New-Object System.Drawing.Point(445, 60)
    $btnRunCmd.Size = New-Object System.Drawing.Size(135, 30)
    $btnRunCmd.BackColor = $diagColor; $btnRunCmd.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnRunCmd.FlatStyle = 'Flat'; $btnRunCmd.FlatAppearance.BorderSize = 0
    $btnRunCmd.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnRunCmd.Enabled = $false; $btnRunCmd.TabStop = $false
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
    $btnInstall.BackColor = $actionColor; $btnInstall.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnInstall.FlatStyle = 'Flat'; $btnInstall.FlatAppearance.BorderSize = 0
    $btnInstall.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnInstall.Enabled = $false; $btnInstall.TabStop = $false
    $form.Controls.Add($btnInstall)

    $btnOpenInstallers = New-Object System.Windows.Forms.Button
    $btnOpenInstallers.Text = "Open Folder"
    $btnOpenInstallers.Location = New-Object System.Drawing.Point(545, 100)
    $btnOpenInstallers.Size = New-Object System.Drawing.Size(100, 30)
    $btnOpenInstallers.BackColor = $panelColor; $btnOpenInstallers.ForeColor = $textColor
    $btnOpenInstallers.FlatStyle = 'Flat'; $btnOpenInstallers.FlatAppearance.BorderSize = 0
    $btnOpenInstallers.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnOpenInstallers.TabStop = $false
    $form.Controls.Add($btnOpenInstallers)

    $btnRefreshList = New-Object System.Windows.Forms.Button
    $btnRefreshList.Text = "🔄"
    $btnRefreshList.Location = New-Object System.Drawing.Point(655, 100)
    $btnRefreshList.Size = New-Object System.Drawing.Size(30, 30)
    $btnRefreshList.BackColor = $panelColor; $btnRefreshList.ForeColor = $textColor
    $btnRefreshList.FlatStyle = 'Flat'; $btnRefreshList.FlatAppearance.BorderSize = 0
    $btnRefreshList.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 14, [System.Drawing.FontStyle]::Bold)
    $btnRefreshList.TabStop = $false
    $form.Controls.Add($btnRefreshList)

    # 3-й ряд (Действия)
    $btnClearTemp = New-Object System.Windows.Forms.Button
    $btnClearTemp.Text = "Clear Temp"
    $btnClearTemp.Location = New-Object System.Drawing.Point(10, 140)
    $btnClearTemp.Size = New-Object System.Drawing.Size(135, 30)
    $btnClearTemp.BackColor = $actionColor; $btnClearTemp.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnClearTemp.FlatStyle = 'Flat'; $btnClearTemp.FlatAppearance.BorderSize = 0
    $btnClearTemp.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnClearTemp.Enabled = $false; $btnClearTemp.TabStop = $false
    $form.Controls.Add($btnClearTemp)

    $btnFixSpooler = New-Object System.Windows.Forms.Button
    $btnFixSpooler.Text = "Fix Spooler"
    $btnFixSpooler.Location = New-Object System.Drawing.Point(155, 140)
    $btnFixSpooler.Size = New-Object System.Drawing.Size(135, 30)
    $btnFixSpooler.BackColor = $actionColor; $btnFixSpooler.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnFixSpooler.FlatStyle = 'Flat'; $btnFixSpooler.FlatAppearance.BorderSize = 0
    $btnFixSpooler.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnFixSpooler.Enabled = $false; $btnFixSpooler.TabStop = $false
    $form.Controls.Add($btnFixSpooler)

    $btnUpdates = New-Object System.Windows.Forms.Button
    $btnUpdates.Text = "Win Updates"
    $btnUpdates.Location = New-Object System.Drawing.Point(300, 140)
    $btnUpdates.Size = New-Object System.Drawing.Size(135, 30)
    $btnUpdates.BackColor = $actionColor; $btnUpdates.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnUpdates.FlatStyle = 'Flat'; $btnUpdates.FlatAppearance.BorderSize = 0
    $btnUpdates.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnUpdates.Enabled = $false; $btnUpdates.TabStop = $false
    $form.Controls.Add($btnUpdates)

    $btnReboot = New-Object System.Windows.Forms.Button
    $btnReboot.Text = "Reboot PC"
    $btnReboot.Location = New-Object System.Drawing.Point(445, 140) 
    $btnReboot.Size = New-Object System.Drawing.Size(135, 30)
    $btnReboot.BackColor = $dangerColor; $btnReboot.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnReboot.FlatStyle = 'Flat'; $btnReboot.FlatAppearance.BorderSize = 0
    $btnReboot.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnReboot.Enabled = $false; $btnReboot.TabStop = $false
    $form.Controls.Add($btnReboot)

    # 4-й ряд (Новые фичи)
    $btnProcesses = New-Object System.Windows.Forms.Button
    $btnProcesses.Text = "Processes"
    $btnProcesses.Location = New-Object System.Drawing.Point(10, 180)
    $btnProcesses.Size = New-Object System.Drawing.Size(135, 30)
    $btnProcesses.BackColor = $diagColor; $btnProcesses.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnProcesses.FlatStyle = 'Flat'; $btnProcesses.FlatAppearance.BorderSize = 0
    $btnProcesses.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnProcesses.Enabled = $false; $btnProcesses.TabStop = $false
    $form.Controls.Add($btnProcesses)

    $btnEventLogs = New-Object System.Windows.Forms.Button
    $btnEventLogs.Text = "Event Logs"
    $btnEventLogs.Location = New-Object System.Drawing.Point(155, 180)
    $btnEventLogs.Size = New-Object System.Drawing.Size(135, 30)
    $btnEventLogs.BackColor = $diagColor; $btnEventLogs.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnEventLogs.FlatStyle = 'Flat'; $btnEventLogs.FlatAppearance.BorderSize = 0
    $btnEventLogs.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnEventLogs.Enabled = $false; $btnEventLogs.TabStop = $false
    $form.Controls.Add($btnEventLogs)

    $btnMassSearch = New-Object System.Windows.Forms.Button
    $btnMassSearch.Text = "Mass Search"
    $btnMassSearch.Location = New-Object System.Drawing.Point(300, 180)
    $btnMassSearch.Size = New-Object System.Drawing.Size(135, 30)
    $btnMassSearch.BackColor = $diagColor; $btnMassSearch.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $btnMassSearch.FlatStyle = 'Flat'; $btnMassSearch.FlatAppearance.BorderSize = 0
    $btnMassSearch.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnMassSearch.Enabled = $false; $btnMassSearch.TabStop = $false
    $form.Controls.Add($btnMassSearch)

    $allActionButtons = @($btnSysInfo, $btnDiskSpace, $btnSearchApps, $btnRunCmd, $btnInstall, $btnClearTemp, $btnFixSpooler, $btnUpdates, $btnReboot, $btnProcesses, $btnEventLogs, $btnMassSearch)

    # --- ОКНО ЛОГА ---
    $global:txtLog = New-Object System.Windows.Forms.TextBox
    $global:txtLog.Location = New-Object System.Drawing.Point(10, 220)
    $global:txtLog.Size = New-Object System.Drawing.Size(725, 380) 
    $global:txtLog.Multiline = $true
    $global:txtLog.ScrollBars = "Vertical"
    $global:txtLog.ReadOnly = $true
    $global:txtLog.BackColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
    $global:txtLog.ForeColor = $accentColor
    $global:txtLog.Font = New-Object System.Drawing.Font("Consolas", 10)
    $global:txtLog.BorderStyle = 'None'
    $form.Controls.Add($global:txtLog)

    # Кнопки логов
    $btnClear = New-Object System.Windows.Forms.Button
    $btnClear.Text = "Clear Log"
    $btnClear.Location = New-Object System.Drawing.Point(10, 610)
    $btnClear.Size = New-Object System.Drawing.Size(100, 25)
    $btnClear.BackColor = $panelColor; $btnClear.ForeColor = $dangerColor
    $btnClear.FlatStyle = 'Flat'; $btnClear.FlatAppearance.BorderSize = 0
    $btnClear.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnClear.TabStop = $false
    $form.Controls.Add($btnClear)

    $btnOpenLogs = New-Object System.Windows.Forms.Button
    $btnOpenLogs.Text = "Open Logs" 
    $btnOpenLogs.Location = New-Object System.Drawing.Point(120, 610)
    $btnOpenLogs.Size = New-Object System.Drawing.Size(100, 25)
    $btnOpenLogs.BackColor = $panelColor; $btnOpenLogs.ForeColor = $diagColor 
    $btnOpenLogs.FlatStyle = 'Flat'; $btnOpenLogs.FlatAppearance.BorderSize = 0
    $btnOpenLogs.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnOpenLogs.TabStop = $false
    $form.Controls.Add($btnOpenLogs)

    # --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ИНТЕРФЕЙСА ---
    function Refresh-InstallerList {
        $cmbInstallers.Items.Clear()
        if (-not (Test-Path $global:InstallerDir)) { New-Item -ItemType Directory -Path $global:InstallerDir -Force | Out-Null }
        $files = Get-ChildItem -Path $global:InstallerDir -Include *.msi, *.exe -File -ErrorAction SilentlyContinue
        if ($files.Count -gt 0) {
            foreach ($file in $files) { [void]$cmbInstallers.Items.Add($file.Name) }
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
        try { & $ActionCode } 
        catch {
            Write-UILog -LogBox $global:txtLog -Message "ERROR: $($_.Exception.Message)" -TargetPC "General" -Color ([System.Drawing.Color]::Red)
            Write-UILog -LogBox $global:txtLog -Message "$($_.Exception.ToString())" -TargetPC "General" -Color ([System.Drawing.Color]::Red)
        } finally {
            $progress.Visible = $false
            $form.Refresh()
        }
    }

    # --- ОБРАБОТЧИКИ ---
    
    # Обработчик Mass Search
    $btnMassSearch.Add_Click({
        $query = [Microsoft.VisualBasic.Interaction]::InputBox("Enter folder name or exact path to search:", "Mass Search", "")
        if (-not $query) { return }

        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Searching for '$query'..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $res = Find-RemoteFolder -Session $global:PSSession -SearchQuery $query
            
            $res | ForEach-Object {
                if ($_.Status -eq "Found") {
                    # ЗЕЛЕНЫЙ ЦВЕТ, ЕСЛИ НАШЛИ
                    Write-UILog -LogBox $global:txtLog -Message "[$($_.PC)] FOUND: $($_.Path)" -TargetPC $_.PC -Color ([System.Drawing.Color]::LightGreen)
                } else {
                    # КРАСНЫЙ ЦВЕТ, ЕСЛИ НЕ НАШЛИ
                    Write-UILog -LogBox $global:txtLog -Message "[$($_.PC)] $($_.Path)" -TargetPC $_.PC -Color ([System.Drawing.Color]::Red)
                }
            }
        }
    })

    $btnOpenInstallers.Add_Click({
        if (-not (Test-Path $global:InstallerDir)) { New-Item -ItemType Directory -Path $global:InstallerDir -Force | Out-Null }
        Start-Process explorer.exe -ArgumentList $global:InstallerDir
    })

    $btnRefreshList.Add_Click({
        Refresh-InstallerList
        Write-UILog -LogBox $global:txtLog -Message "Installer list refreshed." -TargetPC "General" -Color ([System.Drawing.Color]::Gray)
    })

    $btnConnect.Add_Click({
        $rawPCs = $txtPC.Text.Trim()
        if (-not $rawPCs) { return }
        Add-PCHistory -PCString $rawPCs
        $txtPC.Items.Clear()
        if ($global:PCHistory.Count -gt 0) { $txtPC.Items.AddRange($global:PCHistory) }
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
            if ($extension -eq ".msi") { $res = Install-RemoteMsi -Session $global:PSSession -FilePath $filePath } 
            else { $res = Install-RemoteExe -Session $global:PSSession -FilePath $filePath -Arguments $silentArgs }
            $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) }
        }
    })

    $btnSysInfo.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Fetching info..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Get-RemoteSystemInfo -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.Info)" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Cyan) } } })
    $btnRunCmd.Add_Click({ $cmd = [Microsoft.VisualBasic.Interaction]::InputBox("Enter command:", "Run", "Get-Service"); if ($cmd) { Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Executing: $cmd" -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Invoke-RemoteCustomCommand -Session $global:PSSession -Command $cmd; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::White) } } } })
    $btnReboot.Add_Click({ $confirm = [System.Windows.Forms.MessageBox]::Show("Reboot selected PC(s)?", "Confirm", "YesNo", "Question"); if ($confirm -eq "Yes") { Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Sending reboot..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Restart-RemotePC -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } } })
    $btnClearTemp.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Clearing Temp..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Clear-RemoteTemp -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })
    $btnDiskSpace.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Checking Disk Space..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Get-RemoteDiskSpace -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Cyan) } } })
    $btnFixSpooler.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Restarting Spooler..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Restart-RemoteSpooler -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })
    $btnUpdates.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Searching and installing updates (this may take a while)..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Install-RemoteUpdates -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })

    $btnProcesses.Add_Click({
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Fetching processes..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $procs = Get-RemoteProcesses -Session $global:PSSession
            $formProc = New-Object System.Windows.Forms.Form
            $formProc.Text = "Top 20 Processes by RAM"
            $formProc.Size = New-Object System.Drawing.Size(750, 450)
            $formProc.StartPosition = "CenterParent"
            $formProc.BackColor = $bgColor; $formProc.ForeColor = $textColor; $formProc.Icon = $form.Icon
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 10); $grid.Size = New-Object System.Drawing.Size(710, 330)
            $grid.BackgroundColor = $bgColor; $grid.GridColor = $panelColor
            $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.DefaultCellStyle.SelectionBackColor = $accentColor; $grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::Black
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.AllowUserToAddRows = $false; $grid.ReadOnly = $true
            $grid.SelectionMode = 'FullRowSelect'; $grid.MultiSelect = $false
            $grid.DataSource = [System.Collections.ArrayList]@($procs)
            $formProc.Controls.Add($grid)
            $btnKill = New-Object System.Windows.Forms.Button
            $btnKill.Text = "Kill Selected Process"
            $btnKill.Location = New-Object System.Drawing.Point(10, 360); $btnKill.Size = New-Object System.Drawing.Size(200, 30)
            $btnKill.BackColor = $dangerColor; $btnKill.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27)
            $btnKill.FlatStyle = 'Flat'; $btnKill.FlatAppearance.BorderSize = 0
            $btnKill.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
            $formProc.Controls.Add($btnKill)
            $btnKill.Add_Click({
                if ($grid.SelectedRows.Count -eq 0) { return }
                $row = $grid.SelectedRows[0]
                $pId = $row.Cells["Id"].Value; $pName = $row.Cells["ProcessName"].Value; $pComp = $row.Cells["PSComputerName"].Value
                $confirm = [System.Windows.Forms.MessageBox]::Show("Kill process $pName (ID: $pId) on $pComp?", "Confirm", "YesNo", "Warning")
                if ($confirm -eq "Yes") {
                    Write-UILog -LogBox $global:txtLog -Message "Killing process $pName..." -TargetPC $pComp -Color ([System.Drawing.Color]::Yellow)
                    $res = Stop-RemoteProcess -Session $global:PSSession -ProcessId $pId -ProcessName $pName
                    $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) }
                    $formProc.Close()
                }
            })
            $formProc.Add_Shown({ [DarkTitleBar]::Apply($formProc.Handle) })
            $formProc.ShowDialog(); $formProc.Dispose()
        }
    })

    $btnEventLogs.Add_Click({
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Fetching system errors from last 24h..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $logs = Get-RemoteEventLogs -Session $global:PSSession
            $formLogs = New-Object System.Windows.Forms.Form
            $formLogs.Text = "System Errors (Last 24h)"
            $formLogs.Size = New-Object System.Drawing.Size(900, 500)
            $formLogs.StartPosition = "CenterParent"
            $formLogs.BackColor = $bgColor; $formLogs.ForeColor = $textColor; $formLogs.Icon = $form.Icon
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 10); $grid.Size = New-Object System.Drawing.Size(860, 440)
            $grid.BackgroundColor = $bgColor; $grid.GridColor = $panelColor
            $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.DefaultCellStyle.SelectionBackColor = $accentColor; $grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::Black
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.AllowUserToAddRows = $false; $grid.ReadOnly = $true
            $grid.DataSource = [System.Collections.ArrayList]@($logs)
            if ($grid.Columns["Message"]) { $grid.Columns["Message"].AutoSizeMode = 'None'; $grid.Columns["Message"].Width = 200 }
            if ($grid.Columns["TimeCreated"]) { $grid.Columns["TimeCreated"].DefaultCellStyle.Format = 'g' }
            $formLogs.Controls.Add($grid)
            $formLogs.Add_Shown({ [DarkTitleBar]::Apply($formLogs.Handle) })
            $formLogs.ShowDialog(); $formLogs.Dispose()
        }
    })

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
            $formApps.BackColor = $bgColor; $formApps.Icon = $form.Icon
            $lblSearch = New-Object System.Windows.Forms.Label; $lblSearch.Text = "Search:"; $lblSearch.Location = New-Object System.Drawing.Point(10, 15); $lblSearch.ForeColor = $textColor
            $formApps.Controls.Add($lblSearch)
            $txtSearch = New-Object System.Windows.Forms.TextBox; $txtSearch.Location = New-Object System.Drawing.Point(60, 12); $txtSearch.Size = New-Object System.Drawing.Size(710, 20)
            $txtSearch.BackColor = $panelColor; $txtSearch.ForeColor = $textColor; $formApps.Controls.Add($txtSearch)
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 40); $grid.Size = New-Object System.Drawing.Size(760, 400)
            $grid.BackgroundColor = $bgColor; $grid.GridColor = $panelColor
            $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.DefaultCellStyle.SelectionBackColor = $accentColor; $grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::Black
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.AllowUserToAddRows = $false; $grid.ReadOnly = $true
            $grid.DataSource = [System.Collections.ArrayList]@($apps)
            $formApps.Controls.Add($grid)
            $txtSearch.Add_TextChanged({
                $search = $txtSearch.Text
                $filtered = $apps | Where-Object { $_.DisplayName -like "*$search*" -or $_.PSComputerName -like "*$search*" }
                $grid.DataSource = [System.Collections.ArrayList]@($filtered)
            })
            $formApps.Add_Shown({ [DarkTitleBar]::Apply($formApps.Handle) })
            $formApps.ShowDialog(); $formApps.Dispose()
        }
    })

    $btnClear.Add_Click({ $global:txtLog.Clear() })
    $btnOpenLogs.Add_Click({
        $logDir = "C:\Logs"
        if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
        Start-Process explorer.exe -ArgumentList $logDir
    })

    # --- СТАРТ ---
    $form.Add_Shown({ 
        [DarkTitleBar]::Apply($form.Handle)
        Load-PCHistory
        $txtPC.Items.Clear()
        if ($global:PCHistory.Count -gt 0) { 
            $txtPC.Items.AddRange($global:PCHistory)
            $txtPC.Text = $global:PCHistory[0]
        }
        Refresh-InstallerList
        Write-UILog -LogBox $global:txtLog -Message "Program initialized." -TargetPC "General" -Color ([System.Drawing.Color]::Gray)
        $txtPC.Focus() 
    })
    
    [void]$form.ShowDialog()
    Disconnect-RemotePC -Session $global:PSSession
}