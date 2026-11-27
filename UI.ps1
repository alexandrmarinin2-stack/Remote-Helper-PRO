function Show-MainForm {
    # --- СКРЫВАЕМ СИНЕЕ ОКНО КОНСОЛИ ---
    Add-Type -Name Win32 -Namespace Win32 -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow(); [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -ErrorAction SilentlyContinue
    $consolePtr = [Win32.Win32]::GetConsoleWindow()
    [Win32.Win32]::ShowWindow($consolePtr, 0)

    $bgColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
    $panelColor = [System.Drawing.Color]::FromArgb(49, 50, 68)
    $textColor = [System.Drawing.Color]::FromArgb(205, 214, 244)
    $accentColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
    $diagColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
    $actionColor = [System.Drawing.Color]::FromArgb(166, 227, 161)
    $dangerColor = [System.Drawing.Color]::FromArgb(243, 139, 168)
    $tabColor = [System.Drawing.Color]::FromArgb(17, 17, 27)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Remote Helper PRO"
    $form.Size = New-Object System.Drawing.Size(780, 680)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = $bgColor
    $form.ForeColor = $textColor
    $form.FormBorderStyle = 'FixedSingle'
    $form.MaximizeBox = $false
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\imageres.dll")
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    # --- ВЕРХНЯЯ ПАНЕЛЬ ---
    $lblPC = New-Object System.Windows.Forms.Label
    $lblPC.Text = "Имя ПК:"
    $lblPC.Location = New-Object System.Drawing.Point(10, 15)
    $lblPC.Size = New-Object System.Drawing.Size(60, 20)
    $lblPC.ForeColor = $textColor
    $form.Controls.Add($lblPC)

    $txtPC = New-Object System.Windows.Forms.ComboBox
    $txtPC.Location = New-Object System.Drawing.Point(75, 12)
    $txtPC.Size = New-Object System.Drawing.Size(190, 25)
    $txtPC.BackColor = $panelColor
    $txtPC.ForeColor = $textColor
    $txtPC.FlatStyle = 'Flat'
    $txtPC.DropDownStyle = 'DropDown' 
    $txtPC.AutoCompleteMode = 'SuggestAppend'
    $txtPC.AutoCompleteSource = 'ListItems'
    $txtPC.Add_Click({ $txtPC.DroppedDown = $true })
    $form.Controls.Add($txtPC)

    $btnConnect = New-Object System.Windows.Forms.Button
    $btnConnect.Text = "Подключить"
    $btnConnect.Location = New-Object System.Drawing.Point(275, 10)
    $btnConnect.Size = New-Object System.Drawing.Size(100, 28)
    $btnConnect.BackColor = $panelColor
    $btnConnect.ForeColor = [System.Drawing.Color]::LightGreen
    $btnConnect.FlatStyle = 'Flat'
    $btnConnect.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
    $btnConnect.TabStop = $false
    $form.Controls.Add($btnConnect)

    $txtPC.Add_KeyDown({ if ($_.KeyCode -eq 'Enter') { $_.SuppressKeyPress = $true; $btnConnect.PerformClick() } })

    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Text = "Статус: Отключено"
    $lblStatus.Location = New-Object System.Drawing.Point(375, 15)
    $lblStatus.Size = New-Object System.Drawing.Size(160, 20)
    $lblStatus.ForeColor = [System.Drawing.Color]::Red
    $form.Controls.Add($lblStatus)

    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Location = New-Object System.Drawing.Point(650, 12)
    $progress.Size = New-Object System.Drawing.Size(100, 20)
    $progress.Style = 'Marquee'
    $progress.Visible = $false
    $form.Controls.Add($progress)

    $line = New-Object System.Windows.Forms.Label
    $line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $line.Location = New-Object System.Drawing.Point(10, 45)
    $line.Size = New-Object System.Drawing.Size(745, 2)
    $form.Controls.Add($line)

    # ==========================================
    # ВКЛАДКИ
    # ==========================================
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Location = New-Object System.Drawing.Point(10, 55)
    $tabControl.Size = New-Object System.Drawing.Size(745, 220)
    $tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    
    # --- ВКЛАДКА 1: БАЗОВЫЕ ---
    $tabMain = New-Object System.Windows.Forms.TabPage
    $tabMain.Text = "Базовые действия"
    $tabMain.BackColor = $bgColor
    $tabControl.Controls.Add($tabMain)

    $btnSysInfo = New-Object System.Windows.Forms.Button
    $btnSysInfo.Text = "Инфо о ПК"; $btnSysInfo.Location = New-Object System.Drawing.Point(10, 15); $btnSysInfo.Size = New-Object System.Drawing.Size(135, 30)
    $btnSysInfo.BackColor = $diagColor; $btnSysInfo.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnSysInfo.FlatStyle = 'Flat'; $btnSysInfo.Enabled = $false; $btnSysInfo.TabStop = $false
    $tabMain.Controls.Add($btnSysInfo)

    $btnDiskSpace = New-Object System.Windows.Forms.Button
    $btnDiskSpace.Text = "Место на диске"; $btnDiskSpace.Location = New-Object System.Drawing.Point(155, 15); $btnDiskSpace.Size = New-Object System.Drawing.Size(135, 30)
    $btnDiskSpace.BackColor = $diagColor; $btnDiskSpace.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnDiskSpace.FlatStyle = 'Flat'; $btnDiskSpace.Enabled = $false; $btnDiskSpace.TabStop = $false
    $tabMain.Controls.Add($btnDiskSpace)

    $btnSearchApps = New-Object System.Windows.Forms.Button
    $btnSearchApps.Text = "Поиск программ"; $btnSearchApps.Location = New-Object System.Drawing.Point(300, 15); $btnSearchApps.Size = New-Object System.Drawing.Size(135, 30)
    $btnSearchApps.BackColor = $diagColor; $btnSearchApps.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnSearchApps.FlatStyle = 'Flat'; $btnSearchApps.Enabled = $false; $btnSearchApps.TabStop = $false
    $tabMain.Controls.Add($btnSearchApps)

    $btnRunCmd = New-Object System.Windows.Forms.Button
    $btnRunCmd.Text = "Выполнить команду"; $btnRunCmd.Location = New-Object System.Drawing.Point(445, 15); $btnRunCmd.Size = New-Object System.Drawing.Size(135, 30)
    $btnRunCmd.BackColor = $diagColor; $btnRunCmd.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnRunCmd.FlatStyle = 'Flat'; $btnRunCmd.Enabled = $false; $btnRunCmd.TabStop = $false
    $tabMain.Controls.Add($btnRunCmd)

    $btnClearTemp = New-Object System.Windows.Forms.Button
    $btnClearTemp.Text = "Очистить Temp"; $btnClearTemp.Location = New-Object System.Drawing.Point(10, 55); $btnClearTemp.Size = New-Object System.Drawing.Size(135, 30)
    $btnClearTemp.BackColor = $actionColor; $btnClearTemp.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnClearTemp.FlatStyle = 'Flat'; $btnClearTemp.Enabled = $false; $btnClearTemp.TabStop = $false
    $tabMain.Controls.Add($btnClearTemp)

    $btnFixSpooler = New-Object System.Windows.Forms.Button
    $btnFixSpooler.Text = "Починить печать"; $btnFixSpooler.Location = New-Object System.Drawing.Point(155, 55); $btnFixSpooler.Size = New-Object System.Drawing.Size(135, 30)
    $btnFixSpooler.BackColor = $actionColor; $btnFixSpooler.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnFixSpooler.FlatStyle = 'Flat'; $btnFixSpooler.Enabled = $false; $btnFixSpooler.TabStop = $false
    $tabMain.Controls.Add($btnFixSpooler)

    $btnUpdates = New-Object System.Windows.Forms.Button
    $btnUpdates.Text = "Обновления Win"; $btnUpdates.Location = New-Object System.Drawing.Point(300, 55); $btnUpdates.Size = New-Object System.Drawing.Size(135, 30)
    $btnUpdates.BackColor = $actionColor; $btnUpdates.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnUpdates.FlatStyle = 'Flat'; $btnUpdates.Enabled = $false; $btnUpdates.TabStop = $false
    $tabMain.Controls.Add($btnUpdates)

    $btnReboot = New-Object System.Windows.Forms.Button
    $btnReboot.Text = "Перезагрузка"; $btnReboot.Location = New-Object System.Drawing.Point(445, 55); $btnReboot.Size = New-Object System.Drawing.Size(135, 30)
    $btnReboot.BackColor = $dangerColor; $btnReboot.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnReboot.FlatStyle = 'Flat'; $btnReboot.Enabled = $false; $btnReboot.TabStop = $false
    $tabMain.Controls.Add($btnReboot)

    $btnProcesses = New-Object System.Windows.Forms.Button
    $btnProcesses.Text = "Процессы"; $btnProcesses.Location = New-Object System.Drawing.Point(10, 95); $btnProcesses.Size = New-Object System.Drawing.Size(135, 30)
    $btnProcesses.BackColor = $diagColor; $btnProcesses.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnProcesses.FlatStyle = 'Flat'; $btnProcesses.Enabled = $false; $btnProcesses.TabStop = $false
    $tabMain.Controls.Add($btnProcesses)

    $btnEventLogs = New-Object System.Windows.Forms.Button
    $btnEventLogs.Text = "Журналы Windows"; $btnEventLogs.Location = New-Object System.Drawing.Point(155, 95); $btnEventLogs.Size = New-Object System.Drawing.Size(135, 30)
    $btnEventLogs.BackColor = $diagColor; $btnEventLogs.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnEventLogs.FlatStyle = 'Flat'; $btnEventLogs.Enabled = $false; $btnEventLogs.TabStop = $false
    $tabMain.Controls.Add($btnEventLogs)

    $btnMassSearch = New-Object System.Windows.Forms.Button
    $btnMassSearch.Text = "Массовый поиск"; $btnMassSearch.Location = New-Object System.Drawing.Point(300, 95); $btnMassSearch.Size = New-Object System.Drawing.Size(135, 30)
    $btnMassSearch.BackColor = $diagColor; $btnMassSearch.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnMassSearch.FlatStyle = 'Flat'; $btnMassSearch.Enabled = $false; $btnMassSearch.TabStop = $false
    $tabMain.Controls.Add($btnMassSearch)

    # --- ВКЛАДКА 2: ПРОДВИНУТЫЕ ---
    $tabAdv = New-Object System.Windows.Forms.TabPage
    $tabAdv.Text = "Продвинутые инструменты"
    $tabAdv.BackColor = $bgColor
    $tabControl.Controls.Add($tabAdv)

    $btnUsers = New-Object System.Windows.Forms.Button
    $btnUsers.Text = "Кто в системе?"; $btnUsers.Location = New-Object System.Drawing.Point(10, 15); $btnUsers.Size = New-Object System.Drawing.Size(135, 30)
    $btnUsers.BackColor = $diagColor; $btnUsers.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnUsers.FlatStyle = 'Flat'; $btnUsers.Enabled = $false; $btnUsers.TabStop = $false
    $tabAdv.Controls.Add($btnUsers)

    $btnServices = New-Object System.Windows.Forms.Button
    $btnServices.Text = "Службы"; $btnServices.Location = New-Object System.Drawing.Point(155, 15); $btnServices.Size = New-Object System.Drawing.Size(135, 30)
    $btnServices.BackColor = $diagColor; $btnServices.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnServices.FlatStyle = 'Flat'; $btnServices.Enabled = $false; $btnServices.TabStop = $false
    $tabAdv.Controls.Add($btnServices)

    $btnFlushDNS = New-Object System.Windows.Forms.Button
    $btnFlushDNS.Text = "Сбросить DNS"; $btnFlushDNS.Location = New-Object System.Drawing.Point(300, 15); $btnFlushDNS.Size = New-Object System.Drawing.Size(135, 30)
    $btnFlushDNS.BackColor = $actionColor; $btnFlushDNS.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnFlushDNS.FlatStyle = 'Flat'; $btnFlushDNS.Enabled = $false; $btnFlushDNS.TabStop = $false
    $tabAdv.Controls.Add($btnFlushDNS)

    $btnOpenPorts = New-Object System.Windows.Forms.Button
    $btnOpenPorts.Text = "Открытые порты"; $btnOpenPorts.Location = New-Object System.Drawing.Point(445, 15); $btnOpenPorts.Size = New-Object System.Drawing.Size(135, 30)
    $btnOpenPorts.BackColor = $diagColor; $btnOpenPorts.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnOpenPorts.FlatStyle = 'Flat'; $btnOpenPorts.Enabled = $false; $btnOpenPorts.TabStop = $false
    $tabAdv.Controls.Add($btnOpenPorts)

    # Удаление папок/файлов
    $lblDelete = New-Object System.Windows.Forms.Label
    $lblDelete.Text = "Путь для удаления:"; $lblDelete.Location = New-Object System.Drawing.Point(10, 65); $lblDelete.Size = New-Object System.Drawing.Size(130, 20); $lblDelete.ForeColor = $textColor
    $tabAdv.Controls.Add($lblDelete)

    $txtDeletePath = New-Object System.Windows.Forms.TextBox
    $txtDeletePath.Location = New-Object System.Drawing.Point(145, 62); $txtDeletePath.Size = New-Object System.Drawing.Size(300, 25)
    $txtDeletePath.BackColor = $panelColor; $txtDeletePath.ForeColor = $textColor; $txtDeletePath.BorderStyle = 'FixedSingle'
    $tabAdv.Controls.Add($txtDeletePath)

    $btnDeletePath = New-Object System.Windows.Forms.Button
    $btnDeletePath.Text = "Удалить"; $btnDeletePath.Location = New-Object System.Drawing.Point(455, 60); $btnDeletePath.Size = New-Object System.Drawing.Size(125, 30)
    $btnDeletePath.BackColor = $dangerColor; $btnDeletePath.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnDeletePath.FlatStyle = 'Flat'; $btnDeletePath.Enabled = $false; $btnDeletePath.TabStop = $false
    $tabAdv.Controls.Add($btnDeletePath)

    $form.Controls.Add($tabControl)
    $allActionButtons = @($btnSysInfo, $btnDiskSpace, $btnSearchApps, $btnRunCmd, $btnClearTemp, $btnFixSpooler, $btnUpdates, $btnReboot, $btnProcesses, $btnEventLogs, $btnMassSearch, $btnUsers, $btnServices, $btnFlushDNS, $btnOpenPorts, $btnDeletePath)

    # --- ОКНО ЛОГА ---
    $global:txtLog = New-Object System.Windows.Forms.TextBox
    $global:txtLog.Location = New-Object System.Drawing.Point(10, 285)
    $global:txtLog.Size = New-Object System.Drawing.Size(745, 245) 
    $global:txtLog.Multiline = $true; $global:txtLog.ScrollBars = "Vertical"; $global:txtLog.ReadOnly = $true
    $global:txtLog.BackColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $global:txtLog.ForeColor = $accentColor
    $global:txtLog.Font = New-Object System.Drawing.Font("Consolas", 10); $global:txtLog.BorderStyle = 'None'
    $form.Controls.Add($global:txtLog)

    # ==========================================
    # БЛОК УСТАНОВКИ (ВНИЗУ)
    # ==========================================
    $lblInstall = New-Object System.Windows.Forms.Label
    $lblInstall.Text = "Установщик:"; $lblInstall.Location = New-Object System.Drawing.Point(10, 545); $lblInstall.Size = New-Object System.Drawing.Size(85, 20); $lblInstall.ForeColor = $textColor
    $form.Controls.Add($lblInstall)

    $cmbInstallers = New-Object System.Windows.Forms.ComboBox
    $cmbInstallers.Location = New-Object System.Drawing.Point(95, 542); $cmbInstallers.Size = New-Object System.Drawing.Size(330, 25)
    $cmbInstallers.BackColor = $panelColor; $cmbInstallers.ForeColor = $textColor; $cmbInstallers.FlatStyle = 'Flat'; $cmbInstallers.DropDownStyle = 'DropDownList'
    $form.Controls.Add($cmbInstallers)

    $btnInstall = New-Object System.Windows.Forms.Button
    $btnInstall.Text = "Установить"; $btnInstall.Location = New-Object System.Drawing.Point(435, 538); $btnInstall.Size = New-Object System.Drawing.Size(100, 30)
    $btnInstall.BackColor = $actionColor; $btnInstall.ForeColor = [System.Drawing.Color]::FromArgb(17, 17, 27); $btnInstall.FlatStyle = 'Flat'; $btnInstall.Enabled = $false; $btnInstall.TabStop = $false
    $form.Controls.Add($btnInstall)

    $btnOpenInstallers = New-Object System.Windows.Forms.Button
    $btnOpenInstallers.Text = "Папка"; $btnOpenInstallers.Location = New-Object System.Drawing.Point(545, 538); $btnOpenInstallers.Size = New-Object System.Drawing.Size(100, 30)
    $btnOpenInstallers.BackColor = $panelColor; $btnOpenInstallers.ForeColor = $textColor; $btnOpenInstallers.FlatStyle = 'Flat'; $btnOpenInstallers.TabStop = $false
    $form.Controls.Add($btnOpenInstallers)

    $btnRefreshList = New-Object System.Windows.Forms.Button
    $btnRefreshList.Text = "🔄"; $btnRefreshList.Location = New-Object System.Drawing.Point(655, 538); $btnRefreshList.Size = New-Object System.Drawing.Size(100, 30)
    $btnRefreshList.BackColor = $panelColor; $btnRefreshList.ForeColor = $textColor; $btnRefreshList.FlatStyle = 'Flat'
    $btnRefreshList.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12, [System.Drawing.FontStyle]::Bold); $btnRefreshList.TabStop = $false
    $form.Controls.Add($btnRefreshList)

    # Кнопки логов
    $btnClear = New-Object System.Windows.Forms.Button
    $btnClear.Text = "Очистить лог"; $btnClear.Location = New-Object System.Drawing.Point(10, 585); $btnClear.Size = New-Object System.Drawing.Size(100, 25)
    $btnClear.BackColor = $panelColor; $btnClear.ForeColor = $dangerColor; $btnClear.FlatStyle = 'Flat'; $btnClear.TabStop = $false
    $form.Controls.Add($btnClear)

    $btnOpenLogs = New-Object System.Windows.Forms.Button
    $btnOpenLogs.Text = "Открыть логи"; $btnOpenLogs.Location = New-Object System.Drawing.Point(120, 585); $btnOpenLogs.Size = New-Object System.Drawing.Size(100, 25)
    $btnOpenLogs.BackColor = $panelColor; $btnOpenLogs.ForeColor = $diagColor; $btnOpenLogs.FlatStyle = 'Flat'; $btnOpenLogs.TabStop = $false
    $form.Controls.Add($btnOpenLogs)

    # --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ИНТЕРФЕЙСА ---
    function Refresh-InstallerList {
        $cmbInstallers.Items.Clear()
        if (-not (Test-Path $global:InstallerDir)) { New-Item -ItemType Directory -Path $global:InstallerDir -Force | Out-Null }
        $files = Get-ChildItem -Path $global:InstallerDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '^\.(msi|exe)$' }
        if ($files.Count -gt 0) {
            foreach ($file in $files) { [void]$cmbInstallers.Items.Add($file.Name) }
            $cmbInstallers.SelectedIndex = 0
        } else {
            [void]$cmbInstallers.Items.Add("-- Установщики не найдены --")
            $cmbInstallers.SelectedIndex = 0
        }
    }

    function Execute-AsyncAction {
        param([ScriptBlock]$ActionCode)
        $progress.Visible = $true; $form.Refresh()
        try { & $ActionCode } 
        catch {
            Write-UILog -LogBox $global:txtLog -Message "ОШИБКА: $($_.Exception.Message)" -TargetPC "General" -Color ([System.Drawing.Color]::Red)
        } finally { $progress.Visible = $false; $form.Refresh() }
    }

    # --- ОБРАБОТЧИКИ БАЗОВЫХ КНОПОК ---
    $btnMassSearch.Add_Click({
        $query = [Microsoft.VisualBasic.Interaction]::InputBox("Введите имя папки или точный путь:", "Массовый поиск", "")
        if (-not $query) { return }
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Поиск '$query'..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $res = Find-RemoteFolder -Session $global:PSSession -SearchQuery $query
            $res | ForEach-Object {
                if ($_.Status -eq "Found") { Write-UILog -LogBox $global:txtLog -Message "[$($_.PC)] НАЙДЕНО: $($_.Path)" -TargetPC $_.PC -Color ([System.Drawing.Color]::LightGreen) } 
                else { Write-UILog -LogBox $global:txtLog -Message "[$($_.PC)] НЕ НАЙДЕНО" -TargetPC $_.PC -Color ([System.Drawing.Color]::Red) }
            }
        }
    })
    $btnOpenInstallers.Add_Click({ if (-not (Test-Path $global:InstallerDir)) { New-Item -ItemType Directory -Path $global:InstallerDir -Force | Out-Null }; Start-Process explorer.exe -ArgumentList $global:InstallerDir })
    $btnRefreshList.Add_Click({ Refresh-InstallerList; Write-UILog -LogBox $global:txtLog -Message "Список обновлен." -TargetPC "General" -Color ([System.Drawing.Color]::Gray) })
    
    $btnConnect.Add_Click({
        $rawPCs = $txtPC.Text.Trim(); if (-not $rawPCs) { return }
        Add-PCHistory -PCString $rawPCs
        $txtPC.Items.Clear(); if ($global:PCHistory.Count -gt 0) { $txtPC.Items.AddRange($global:PCHistory) }
        $pcList = $rawPCs -split '[, ]+' | Where-Object { $_ -ne "" }
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Подключение..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $lblStatus.Text = "Статус: Подключение..."; $lblStatus.ForeColor = [System.Drawing.Color]::Orange
            try {
                $global:PSSession = Connect-ToRemotePC -TargetPCs $pcList
                $lblStatus.Text = "Статус: Подключено ($($pcList.Count))"; $lblStatus.ForeColor = [System.Drawing.Color]::Green
                Write-UILog -LogBox $global:txtLog -Message "Успешно!" -TargetPC "General" -Color ([System.Drawing.Color]::Green)
                foreach ($b in $allActionButtons) { $b.Enabled = $true }
            } catch {
                $lblStatus.Text = "Статус: Ошибка"; $lblStatus.ForeColor = [System.Drawing.Color]::Red
                Write-UILog -LogBox $global:txtLog -Message "Ошибка: $($_.Exception.Message)" -TargetPC "General" -Color ([System.Drawing.Color]::Red)
                foreach ($b in $allActionButtons) { $b.Enabled = $false }
            }
        }
    })

    $btnInstall.Add_Click({
        $selectedItem = $cmbInstallers.SelectedItem.ToString()
        if ($selectedItem -match "не найдены") { return }
        $filePath = Join-Path $global:InstallerDir $selectedItem
        $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
        $defaultArgs = if ($extension -eq ".msi") { "/qn /norestart" } else { "/S" }
        $silentArgs = [Microsoft.VisualBasic.Interaction]::InputBox("Ключи установки:", "Установка", $defaultArgs)
        if ($silentArgs -eq $null) { return }
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Установка $selectedItem..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            if ($extension -eq ".msi") { $res = Install-RemoteMsi -Session $global:PSSession -FilePath $filePath } 
            else { $res = Install-RemoteExe -Session $global:PSSession -FilePath $filePath -Arguments $silentArgs }
            $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) }
        }
    })
    $btnSysInfo.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Инфо..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Get-RemoteSystemInfo -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.Info)" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Cyan) } } })
    $btnRunCmd.Add_Click({ $cmd = [Microsoft.VisualBasic.Interaction]::InputBox("Введите команду:", "Выполнить", "Get-Service"); if ($cmd) { Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Выполнение: $cmd" -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Invoke-RemoteCustomCommand -Session $global:PSSession -Command $cmd; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::White) } } } })
    $btnReboot.Add_Click({ $confirm = [System.Windows.Forms.MessageBox]::Show("Перезагрузить?", "Вопрос", "YesNo", "Question"); if ($confirm -eq "Yes") { Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Перезагрузка..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Restart-RemotePC -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } } })
    $btnClearTemp.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Очистка Temp..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Clear-RemoteTemp -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })
    $btnDiskSpace.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Диски..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Get-RemoteDiskSpace -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $_" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Cyan) } } })
    $btnFixSpooler.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Печать..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); (Restart-RemoteSpooler -Session $global:PSSession) | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })
    $btnUpdates.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Обновления..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Install-RemoteUpdates -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })

    $btnProcesses.Add_Click({
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Процессы..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $procs = Get-RemoteProcesses -Session $global:PSSession
            $formProc = New-Object System.Windows.Forms.Form; $formProc.Text = "Процессы"; $formProc.Size = New-Object System.Drawing.Size(750, 450)
            $formProc.BackColor = $bgColor; $formProc.ForeColor = $textColor; $formProc.Font = $form.Font
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 10); $grid.Size = New-Object System.Drawing.Size(710, 330)
            $grid.BackgroundColor = $bgColor; $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.ReadOnly = $true; $grid.DataSource = [System.Collections.ArrayList]@($procs)
            $formProc.Controls.Add($grid)
            $btnKill = New-Object System.Windows.Forms.Button; $btnKill.Text = "Завершить"; $btnKill.Location = New-Object System.Drawing.Point(10, 360); $btnKill.BackColor = $dangerColor; $btnKill.FlatStyle = 'Flat'
            $formProc.Controls.Add($btnKill)
            $btnKill.Add_Click({
                if ($grid.SelectedRows.Count -eq 0) { return }
                $row = $grid.SelectedRows[0]; $pId = $row.Cells["Id"].Value; $pName = $row.Cells["ProcessName"].Value; $pComp = $row.Cells["PSComputerName"].Value
                if ([System.Windows.Forms.MessageBox]::Show("Убить $pName?", "Да", "YesNo") -eq "Yes") {
                    Write-UILog -LogBox $global:txtLog -Message "Убиваем $pName..." -TargetPC $pComp -Color ([System.Drawing.Color]::Yellow)
                    $res = Stop-RemoteProcess -Session $global:PSSession -ProcessId $pId -ProcessName $pName
                    $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) }
                    $formProc.Close()
                }
            })
            $formProc.ShowDialog(); $formProc.Dispose()
        }
    })

    $btnEventLogs.Add_Click({
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Журналы..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $logs = Get-RemoteEventLogs -Session $global:PSSession
            $formLogs = New-Object System.Windows.Forms.Form; $formLogs.Text = "Ошибки"; $formLogs.Size = New-Object System.Drawing.Size(900, 500)
            $formLogs.BackColor = $bgColor; $formLogs.ForeColor = $textColor; $formLogs.Font = $form.Font
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 10); $grid.Size = New-Object System.Drawing.Size(860, 440)
            $grid.BackgroundColor = $bgColor; $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.ReadOnly = $true; $grid.DataSource = [System.Collections.ArrayList]@($logs)
            if ($grid.Columns["Message"]) { $grid.Columns["Message"].AutoSizeMode = 'None'; $grid.Columns["Message"].Width = 200 }
            $formLogs.Controls.Add($grid); $formLogs.ShowDialog(); $formLogs.Dispose()
        }
    })

    $btnSearchApps.Add_Click({
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Список программ..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $apps = Invoke-Command -Session $global:PSSession -ScriptBlock { Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName } | Select-Object PSComputerName, DisplayName, DisplayVersion }
            $formApps = New-Object System.Windows.Forms.Form; $formApps.Text = "Программы"; $formApps.Size = New-Object System.Drawing.Size(800, 500)
            $formApps.BackColor = $bgColor; $formApps.Font = $form.Font
            $txtSearch = New-Object System.Windows.Forms.TextBox; $txtSearch.Location = New-Object System.Drawing.Point(60, 12); $txtSearch.Size = New-Object System.Drawing.Size(710, 20); $txtSearch.BackColor = $panelColor; $txtSearch.ForeColor = $textColor
            $formApps.Controls.Add($txtSearch)
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 40); $grid.Size = New-Object System.Drawing.Size(760, 400)
            $grid.BackgroundColor = $bgColor; $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.ReadOnly = $true; $grid.DataSource = [System.Collections.ArrayList]@($apps)
            $formApps.Controls.Add($grid)
            $txtSearch.Add_TextChanged({ $filtered = $apps | Where-Object { $_.DisplayName -like "*$($txtSearch.Text)*" -or $_.PSComputerName -like "*$($txtSearch.Text)*" }; $grid.DataSource = [System.Collections.ArrayList]@($filtered) })
            $formApps.ShowDialog(); $formApps.Dispose()
        }
    })

    # --- ОБРАБОТЧИКИ ПРОДВИНУТЫХ КНОПОК ---
    $btnUsers.Add_Click({
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Поиск активных сессий..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $sessions = Get-RemoteSessions -Session $global:PSSession
            if (-not $sessions) { Write-UILog -LogBox $global:txtLog -Message "Нет активных пользователей." -TargetPC "General" -Color ([System.Drawing.Color]::Cyan); return }

            $formUsers = New-Object System.Windows.Forms.Form; $formUsers.Text = "Активные сессии"; $formUsers.Size = New-Object System.Drawing.Size(600, 350)
            $formUsers.BackColor = $bgColor; $formUsers.ForeColor = $textColor; $formUsers.Font = $form.Font
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 10); $grid.Size = New-Object System.Drawing.Size(560, 230)
            $grid.BackgroundColor = $bgColor; $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.ReadOnly = $true; $grid.SelectionMode = 'FullRowSelect'
            $grid.DataSource = [System.Collections.ArrayList]@($sessions)
            $formUsers.Controls.Add($grid)
            
            $btnLogoff = New-Object System.Windows.Forms.Button; $btnLogoff.Text = "Выйти (Logoff)"; $btnLogoff.Location = New-Object System.Drawing.Point(10, 260)
            $btnLogoff.Size = New-Object System.Drawing.Size(150, 30); $btnLogoff.BackColor = $dangerColor; $btnLogoff.FlatStyle = 'Flat'
            $formUsers.Controls.Add($btnLogoff)
            
            $btnLogoff.Add_Click({
                if ($grid.SelectedRows.Count -eq 0) { return }
                $row = $grid.SelectedRows[0]; $sId = $row.Cells["ID"].Value
                if ([System.Windows.Forms.MessageBox]::Show("Выгнать пользователя?", "Вопрос", "YesNo") -eq "Yes") {
                    Write-UILog -LogBox $global:txtLog -Message "Выход сессии $sId..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
                    $res = Stop-RemoteSession -Session $global:PSSession -SessionId $sId
                    $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message $_ -TargetPC "General" -Color ([System.Drawing.Color]::Green) }
                    $formUsers.Close()
                }
            })
            $formUsers.ShowDialog(); $formUsers.Dispose()
        }
    })

    $btnServices.Add_Click({
        $filter = [Microsoft.VisualBasic.Interaction]::InputBox("Введите имя службы (например, Spooler, SQL, 1C):", "Поиск служб", "")
        if ($filter -eq $null) { return }
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Поиск служб '$filter'..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $services = Get-RemoteServices -Session $global:PSSession -Filter $filter
            if (-not $services) { Write-UILog -LogBox $global:txtLog -Message "Службы не найдены." -TargetPC "General" -Color ([System.Drawing.Color]::Red); return }

            $formSrv = New-Object System.Windows.Forms.Form; $formSrv.Text = "Службы"; $formSrv.Size = New-Object System.Drawing.Size(700, 400)
            $formSrv.BackColor = $bgColor; $formSrv.ForeColor = $textColor; $formSrv.Font = $form.Font
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 10); $grid.Size = New-Object System.Drawing.Size(660, 280)
            $grid.BackgroundColor = $bgColor; $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.ReadOnly = $true; $grid.SelectionMode = 'FullRowSelect'
            $grid.DataSource = [System.Collections.ArrayList]@($services)
            $formSrv.Controls.Add($grid)
            
            $btnRestartSrv = New-Object System.Windows.Forms.Button; $btnRestartSrv.Text = "Перезапустить службу"; $btnRestartSrv.Location = New-Object System.Drawing.Point(10, 310)
            $btnRestartSrv.Size = New-Object System.Drawing.Size(200, 30); $btnRestartSrv.BackColor = $actionColor; $btnRestartSrv.FlatStyle = 'Flat'
            $formSrv.Controls.Add($btnRestartSrv)
            
            $btnRestartSrv.Add_Click({
                if ($grid.SelectedRows.Count -eq 0) { return }
                $row = $grid.SelectedRows[0]; $sName = $row.Cells["Name"].Value
                Write-UILog -LogBox $global:txtLog -Message "Перезапуск $sName..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
                $res = Restart-RemoteService -Session $global:PSSession -ServiceName $sName
                $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message $_ -TargetPC "General" -Color ([System.Drawing.Color]::Green) }
                $formSrv.Close()
            })
            $formSrv.ShowDialog(); $formSrv.Dispose()
        }
    })

    $btnFlushDNS.Add_Click({ Execute-AsyncAction { Write-UILog -LogBox $global:txtLog -Message "Сброс DNS..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow); $res = Clear-RemoteDNS -Session $global:PSSession; $res | ForEach-Object { Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color ([System.Drawing.Color]::Green) } } })

    $btnOpenPorts.Add_Click({
        Execute-AsyncAction {
            Write-UILog -LogBox $global:txtLog -Message "Открытые порты..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
            $ports = Get-RemoteOpenPorts -Session $global:PSSession
            $formPorts = New-Object System.Windows.Forms.Form; $formPorts.Text = "Прослушиваемые порты"; $formPorts.Size = New-Object System.Drawing.Size(750, 450)
            $formPorts.BackColor = $bgColor; $formPorts.ForeColor = $textColor; $formPorts.Font = $form.Font
            $grid = New-Object System.Windows.Forms.DataGridView
            $grid.Location = New-Object System.Drawing.Point(10, 10); $grid.Size = New-Object System.Drawing.Size(710, 380)
            $grid.BackgroundColor = $bgColor; $grid.DefaultCellStyle.BackColor = $bgColor; $grid.DefaultCellStyle.ForeColor = $textColor
            $grid.AutoSizeColumnsMode = 'Fill'; $grid.ReadOnly = $true
            $grid.DataSource = [System.Collections.ArrayList]@($ports)
            $formPorts.Controls.Add($grid); $formPorts.ShowDialog(); $formPorts.Dispose()
        }
    })

    $btnDeletePath.Add_Click({
        $path = $txtDeletePath.Text.Trim()
        if (-not $path) { return }
        $confirm = [System.Windows.Forms.MessageBox]::Show("УДАЛИТЬ '$path' НА ВСЕХ ПК?`nЭто действие необратимо!", "ВНИМАНИЕ", "YesNo", "Warning")
        if ($confirm -eq "Yes") {
            Execute-AsyncAction {
                Write-UILog -LogBox $global:txtLog -Message "Удаление '$path'..." -TargetPC "General" -Color ([System.Drawing.Color]::Yellow)
                $res = Remove-RemoteItem -Session $global:PSSession -Path $path
                $res | ForEach-Object { 
                    $color = if ($_.ToString() -match "Ошибка") { [System.Drawing.Color]::Red } else { [System.Drawing.Color]::LightGreen }
                    Write-UILog -LogBox $global:txtLog -Message "[$($_.PSComputerName)] $($_.ToString())" -TargetPC $_.PSComputerName -Color $color 
                }
            }
        }
    })

    $btnClear.Add_Click({ $global:txtLog.Clear() })
    $btnOpenLogs.Add_Click({ Start-Process explorer.exe -ArgumentList "C:\Logs" })

    # --- СТАРТ ---
    $form.Add_Shown({ 
        [DarkTitleBar]::Apply($form.Handle)
        Load-PCHistory
        $txtPC.Items.Clear()
        if ($global:PCHistory.Count -gt 0) { $txtPC.Items.AddRange($global:PCHistory); $txtPC.Text = $global:PCHistory[0] }
        Refresh-InstallerList
        Write-UILog -LogBox $global:txtLog -Message "Программа запущена." -TargetPC "General" -Color ([System.Drawing.Color]::Gray)
        $txtPC.Focus() 
    })
    
    [void]$form.ShowDialog()
    Disconnect-RemotePC -Session $global:PSSession
}