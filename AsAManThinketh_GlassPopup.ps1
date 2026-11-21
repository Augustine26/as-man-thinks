#requires -Version 5.1
# As A Man Thinketh — Glassmorphism Windows Desktop Popup App (WPF + Acrylic Blur + Animated Stroke)

# Ensure STA (Single-Threaded Apartment) mode so WPF always runs reliably
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    powershell.exe -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "`"$PSCommandPath`""
    exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Enable Windows 10/11 Frosted Glass (Acrylic / BlurBehind) via DWM API
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class GlassEffect {
    [StructLayout(LayoutKind.Sequential)]
    internal struct WindowCompositionAttributeData {
        public int Attribute;
        public IntPtr Data;
        public int SizeOfData;
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct AccentPolicy {
        public int AccentState;
        public int AccentFlags;
        public uint GradientColor;
        public int AnimationId;
    }

    [DllImport("user32.dll")]
    internal static extern int SetWindowCompositionAttribute(IntPtr hwnd, ref WindowCompositionAttributeData data);

    public static void EnableGlass(IntPtr hwnd) {
        AccentPolicy accent = new AccentPolicy();
        accent.AccentState = 3; // ACCENT_ENABLE_BLURBEHIND (Frosted Glass)
        accent.AccentFlags = 2;
        accent.GradientColor = 0x9912161F; // Translucent dark tint

        int accentStructSize = Marshal.SizeOf(accent);
        IntPtr accentPtr = Marshal.AllocHGlobal(accentStructSize);
        Marshal.StructureToPtr(accent, accentPtr, false);

        WindowCompositionAttributeData data = new WindowCompositionAttributeData();
        data.Attribute = 19; // WCA_ACCENT_POLICY
        data.SizeOfData = accentStructSize;
        data.Data = accentPtr;

        SetWindowCompositionAttribute(hwnd, ref data);
        Marshal.FreeHGlobal(accentPtr);
    }
}
"@

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$quotesPath = Join-Path $scriptDir "quotes.json"
$quotes = Get-Content -Path $quotesPath -Raw -Encoding UTF8 | ConvertFrom-Json

$script:intervalMinutes = 60
$script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
$script:activePopup = $null

# Hidden WPF Application Host so the message loop NEVER exits prematurely
$app = New-Object System.Windows.Application
$app.ShutdownMode = [System.Windows.ShutdownMode]::OnExplicitShutdown

# System Tray Icon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
$notifyIcon.Text = "As A Man Thinketh — Glass Wisdom"
$notifyIcon.Visible = $true

function Show-GlassPopup {
    param($quoteObj)

    if ($null -ne $script:activePopup) {
        try { $script:activePopup.Close() } catch {}
    }

    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="As A Man Thinketh"
        Width="440" Height="235"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        ResizeMode="NoResize"
        Opacity="0">
    <Window.Triggers>
        <EventTrigger RoutedEvent="Window.Loaded">
            <BeginStoryboard>
                <Storyboard>
                    <!-- Smooth Glass Fade-In -->
                    <DoubleAnimation Storyboard.TargetProperty="Opacity" From="0" To="1" Duration="0:0:0.45"/>
                    <!-- Continuous Animated Gradient Stroke Rotation -->
                    <DoubleAnimation Storyboard.TargetName="StrokeAngle"
                                     Storyboard.TargetProperty="Angle"
                                     From="0" To="360"
                                     Duration="0:0:6"
                                     RepeatBehavior="Forever"/>
                    <!-- Subtle Breathing Glow on Stroke -->
                    <DoubleAnimation Storyboard.TargetName="GlowEffect"
                                     Storyboard.TargetProperty="BlurRadius"
                                     From="8" To="20"
                                     Duration="0:0:2.5"
                                     AutoReverse="True"
                                     RepeatBehavior="Forever"/>
                </Storyboard>
            </BeginStoryboard>
        </EventTrigger>
    </Window.Triggers>

    <Grid Margin="12">
        <!-- Animated Luminous Border Stroke -->
        <Border CornerRadius="18" Padding="1.8">
            <Border.Effect>
                <DropShadowEffect x:Name="GlowEffect" Color="#F5D061" BlurRadius="14" ShadowDepth="0" Opacity="0.55"/>
            </Border.Effect>
            <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <LinearGradientBrush.RelativeTransform>
                        <RotateTransform x:Name="StrokeAngle" CenterX="0.5" CenterY="0.5" Angle="0"/>
                    </LinearGradientBrush.RelativeTransform>
                    <GradientStop Color="#FFF5D061" Offset="0.0"/>
                    <GradientStop Color="#55FFFFFF" Offset="0.35"/>
                    <GradientStop Color="#2238BDF8" Offset="0.65"/>
                    <GradientStop Color="#FFD4AF37" Offset="1.0"/>
                </LinearGradientBrush>
            </Border.Background>

            <!-- Frosted Glass Inner Card -->
            <Border CornerRadius="16.5" Padding="20,16">
                <Border.Background>
                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                        <GradientStop Color="#CC161B26" Offset="0"/>
                        <GradientStop Color="#B81E2636" Offset="1"/>
                    </LinearGradientBrush>
                </Border.Background>

                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- Top Bar: Chapter Tag + Close -->
                    <Grid Grid.Row="0" Margin="0,0,0,10">
                        <Border Background="#26F5D061" BorderBrush="#55F5D061" BorderThickness="1"
                                CornerRadius="8" Padding="10,4" HorizontalAlignment="Left">
                            <TextBlock x:Name="TxtChapter"
                                       Text="CHAPTER"
                                       Foreground="#F5D061"
                                       FontFamily="Segoe UI"
                                       FontSize="10"
                                       FontWeight="Bold"/>
                        </Border>

                        <Button x:Name="BtnClose"
                                Content="✕"
                                HorizontalAlignment="Right"
                                VerticalAlignment="Center"
                                Width="26" Height="26"
                                Foreground="#CBD5E1"
                                Background="#1FFFFFFF"
                                BorderThickness="0"
                                FontSize="11"
                                Cursor="Hand">
                            <Button.Resources>
                                <Style TargetType="Border">
                                    <Setter Property="CornerRadius" Value="13"/>
                                </Style>
                            </Button.Resources>
                        </Button>
                    </Grid>

                    <!-- Center Quote Text -->
                    <TextBlock x:Name="TxtQuote"
                               Grid.Row="1"
                               Text="Quote goes here..."
                               Foreground="#F8FAFC"
                               FontFamily="Georgia"
                               FontSize="14"
                               FontStyle="Italic"
                               TextWrapping="Wrap"
                               LineHeight="21"
                               VerticalAlignment="Center"/>

                    <!-- Footer: Author + Next Glass Pill Button -->
                    <Grid Grid.Row="2" Margin="0,12,0,0">
                        <TextBlock Text="— James Allen  •  As A Man Thinketh"
                                   Foreground="#94A3B8"
                                   FontFamily="Segoe UI"
                                   FontSize="11"
                                   VerticalAlignment="Center"
                                   HorizontalAlignment="Left"/>

                        <Button x:Name="BtnNext"
                                Content="Next Thought →"
                                HorizontalAlignment="Right"
                                Padding="14,6"
                                Foreground="#0F172A"
                                FontFamily="Segoe UI"
                                FontSize="11"
                                FontWeight="Bold"
                                Cursor="Hand"
                                BorderThickness="0">
                            <Button.Background>
                                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                                    <GradientStop Color="#F5D061" Offset="0"/>
                                    <GradientStop Color="#EAB308" Offset="1"/>
                                </LinearGradientBrush>
                            </Button.Background>
                            <Button.Resources>
                                <Style TargetType="Border">
                                    <Setter Property="CornerRadius" Value="12"/>
                                </Style>
                            </Button.Resources>
                        </Button>
                    </Grid>
                </Grid>
            </Border>
        </Border>
    </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $win = [Windows.Markup.XamlReader]::Load($reader)
    $script:activePopup = $win

    # Populate text
    $win.FindName("TxtChapter").Text = $quoteObj.chapter.ToUpper()
    $win.FindName("TxtQuote").Text = "`"$($quoteObj.quote)`""

    # Position bottom-right above taskbar
    $workArea = [System.Windows.SystemParameters]::WorkArea
    $win.Left = $workArea.Right - $win.Width - 12
    $win.Top = $workArea.Bottom - $win.Height - 12

    # Apply native Windows Frosted Glass Blur on SourceInitialized
    $win.Add_SourceInitialized({
        $helper = New-Object System.Windows.Interop.WindowInteropHelper($win)
        [GlassEffect]::EnableGlass($helper.Handle)
    })

    # Allow dragging the glass card anywhere on screen
    $win.Add_MouseLeftButtonDown({
        try { $win.DragMove() } catch {}
    })

    # Close button
    $win.FindName("BtnClose").Add_Click({
        $win.Close()
    })

    # Next thought button
    $win.FindName("BtnNext").Add_Click({
        $script:currentIndex = ($script:currentIndex + 1) % $quotes.Count
        Show-GlassPopup -quoteObj $quotes[$script:currentIndex]
    })

    # Auto-dismiss timer (25 seconds)
    $autoClose = New-Object System.Windows.Threading.DispatcherTimer
    $autoClose.Interval = [TimeSpan]::FromSeconds(25)
    $autoClose.Add_Tick({
        $autoClose.Stop()
        if ($win.IsVisible) { $win.Close() }
    })
    $autoClose.Start()

    $win.Show()
}

# WPF DispatcherTimer for scheduled background popups (runs reliably on the UI thread!)
$scheduleTimer = New-Object System.Windows.Threading.DispatcherTimer
$scheduleTimer.Interval = [TimeSpan]::FromMinutes($script:intervalMinutes)
$scheduleTimer.Add_Tick({
    $script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
    Show-GlassPopup -quoteObj $quotes[$script:currentIndex]
})
$scheduleTimer.Start()

# System Tray Context Menu
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

$itemNow = $contextMenu.Items.Add("✨ Show Glass Thought Now")
$itemNow.Add_Click({
    $script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
    Show-GlassPopup -quoteObj $quotes[$script:currentIndex]
})

$item15 = $contextMenu.Items.Add("⏱ Every 15 Minutes")
$item15.Add_Click({
    $scheduleTimer.Stop()
    $scheduleTimer.Interval = [TimeSpan]::FromMinutes(15)
    $scheduleTimer.Start()
})

$item60 = $contextMenu.Items.Add("⏱ Every 1 Hour (Default)")
$item60.Add_Click({
    $scheduleTimer.Stop()
    $scheduleTimer.Interval = [TimeSpan]::FromMinutes(60)
    $scheduleTimer.Start()
})

$item180 = $contextMenu.Items.Add("⏱ Every 3 Hours")
$item180.Add_Click({
    $scheduleTimer.Stop()
    $scheduleTimer.Interval = [TimeSpan]::FromMinutes(180)
    $scheduleTimer.Start()
})

$contextMenu.Items.Add("-") | Out-Null

$itemExit = $contextMenu.Items.Add("Exit")
$itemExit.Add_Click({
    $scheduleTimer.Stop()
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
    $app.Shutdown()
})

$notifyIcon.ContextMenuStrip = $contextMenu
$notifyIcon.Add_DoubleClick({
    $script:currentIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
    Show-GlassPopup -quoteObj $quotes[$script:currentIndex]
})

# Show initial glass popup immediately on start
Show-GlassPopup -quoteObj $quotes[$script:currentIndex]

# Run persistent WPF message loop
$app.Run() | Out-Null
