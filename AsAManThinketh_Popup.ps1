Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$quotesPath = Join-Path $scriptDir "quotes.json"
$quotes = Get-Content -Path $quotesPath -Raw -Encoding UTF8 | ConvertFrom-Json

$script:intervalMinutes = 60
$script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count

# Create NotifyIcon (System Tray Icon)
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$notifyIcon.Text = "As A Man Thinketh - Daily Wisdom"
$notifyIcon.Visible = $true

# Custom Sleek Popup Card Function (Like Bible Verse Popups)
function Show-QuotePopup {
    param($quoteObj)

    $popup = New-Object System.Windows.Forms.Form
    $popup.Text = "As A Man Thinketh"
    $popup.Size = New-Object System.Drawing.Size(420, 220)
    $popup.StartPosition = "Manual"
    $popup.FormBorderStyle = "None"
    $popup.TopMost = $true
    $popup.BackColor = [System.Drawing.Color]::FromArgb(28, 32, 38)
    $popup.ShowInTaskbar = $false

    # Position bottom-right above taskbar
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $popup.Location = New-Object System.Drawing.Point(($screen.Right - $popup.Width - 16), ($screen.Bottom - $popup.Height - 16))

    # Accent top border
    $accent = New-Object System.Windows.Forms.Panel
    $accent.Dock = "Top"
    $accent.Height = 4
    $accent.BackColor = [System.Drawing.Color]::FromArgb(212, 175, 55) # Gold accent
    $popup.Controls.Add($accent)

    # Header Label
    $lblHeader = New-Object System.Windows.Forms.Label
    $lblHeader.Text = "AS A MAN THINKETH  •  $($quoteObj.chapter.ToUpper())"
    $lblHeader.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $lblHeader.ForeColor = [System.Drawing.Color]::FromArgb(212, 175, 55)
    $lblHeader.Location = New-Object System.Drawing.Point(18, 16)
    $lblHeader.Size = New-Object System.Drawing.Size(350, 20)
    $popup.Controls.Add($lblHeader)

    # Close Button
    $btnClose = New-Object System.Windows.Forms.Label
    $btnClose.Text = "✕"
    $btnClose.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btnClose.ForeColor = [System.Drawing.Color]::FromArgb(160, 170, 180)
    $btnClose.Location = New-Object System.Drawing.Point(385, 12)
    $btnClose.Size = New-Object System.Drawing.Size(24, 24)
    $btnClose.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnClose.Add_Click({ $popup.Close() })
    $popup.Controls.Add($btnClose)

    # Quote Body
    $lblQuote = New-Object System.Windows.Forms.Label
    $lblQuote.Text = "`"$($quoteObj.quote)`""
    $lblQuote.Font = New-Object System.Drawing.Font("Georgia", 11, [System.Drawing.FontStyle]::Italic)
    $lblQuote.ForeColor = [System.Drawing.Color]::FromArgb(242, 244, 248)
    $lblQuote.Location = New-Object System.Drawing.Point(18, 46)
    $lblQuote.Size = New-Object System.Drawing.Size(384, 115)
    $popup.Controls.Add($lblQuote)

    # Author Footer
    $lblAuthor = New-Object System.Windows.Forms.Label
    $lblAuthor.Text = "— James Allen"
    $lblAuthor.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $lblAuthor.ForeColor = [System.Drawing.Color]::FromArgb(160, 170, 180)
    $lblAuthor.Location = New-Object System.Drawing.Point(18, 172)
    $lblAuthor.Size = New-Object System.Drawing.Size(200, 22)
    $popup.Controls.Add($lblAuthor)

    # Next Quote Button
    $btnNext = New-Object System.Windows.Forms.Button
    $btnNext.Text = "Next Thought →"
    $btnNext.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $btnNext.ForeColor = [System.Drawing.Color]::FromArgb(28, 32, 38)
    $btnNext.BackColor = [System.Drawing.Color]::FromArgb(212, 175, 55)
    $btnNext.FlatStyle = "Flat"
    $btnNext.FlatAppearance.BorderSize = 0
    $btnNext.Location = New-Object System.Drawing.Point(290, 168)
    $btnNext.Size = New-Object System.Drawing.Size(112, 28)
    $btnNext.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnNext.Add_Click({
        $popup.Close()
        $script:currentIndex = ($script:currentIndex + 1) % $quotes.Count
        Show-QuotePopup -quoteObj $quotes[$script:currentIndex]
    })
    $popup.Controls.Add($btnNext)

    # Auto-close timer after 25 seconds unless hovered
    $closeTimer = New-Object System.Windows.Forms.Timer
    $closeTimer.Interval = 25000
    $closeTimer.Add_Tick({
        $closeTimer.Stop()
        if (-not $popup.IsDisposed) { $popup.Close() }
    })
    $closeTimer.Start()

    $popup.Show()
}

# Context Menu for System Tray
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

$menuShowNow = $contextMenu.Items.Add("Show Thought Popup Now")
$menuShowNow.Add_Click({
    $script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
    Show-QuotePopup -quoteObj $quotes[$script:currentIndex]
})

$menu15 = $contextMenu.Items.Add("Interval: Every 15 Minutes")
$menu15.Add_Click({ $timer.Interval = 15 * 60 * 1000 })

$menu60 = $contextMenu.Items.Add("Interval: Every 1 Hour (Default)")
$menu60.Add_Click({ $timer.Interval = 60 * 60 * 1000 })

$menu180 = $contextMenu.Items.Add("Interval: Every 3 Hours")
$menu180.Add_Click({ $timer.Interval = 180 * 60 * 1000 })

$contextMenu.Items.Add("-") | Out-Null

$menuExit = $contextMenu.Items.Add("Exit")
$menuExit.Add_Click({
    $notifyIcon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})

$notifyIcon.ContextMenuStrip = $contextMenu
$notifyIcon.Add_DoubleClick({
    $script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
    Show-QuotePopup -quoteObj $quotes[$script:currentIndex]
})

# Background Timer for Scheduled Popups
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $script:intervalMinutes * 60 * 1000
$timer.Add_Tick({
    $script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
    Show-QuotePopup -quoteObj $quotes[$script:currentIndex]
})
$timer.Start()

# Show initial welcome popup on launch
Show-QuotePopup -quoteObj $quotes[$script:currentIndex]

# Keep app running in system tray
[System.Windows.Forms.Application]::Run()
