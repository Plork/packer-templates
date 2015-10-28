@Echo Setting Registry values
@Echo off
rem  Setting Default HKCU values by loading and modifying the default user registry hive
reg LOAD "HKU\Temp" "%USERPROFILE%\..\Default User\NTUSER.DAT">Nul

REM disable concole QuickEdit
reg ADD "HKU\Temp\Console" /v QuickEdit /t REG_DWORD /d 0 /f>Nul

REM Screen Saver Timeout
reg ADD "HKU\Temp\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut /d "600" /f>Nul
REM Reduce menu show delay
reg ADD "HKU\Temp\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v MenuShowDelay /d "0" /f>Nul
REM Disable Screensaver
reg ADD "HKU\Temp\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveActive /d "0" /f>Nul
REM Screen Save Secure
reg ADD "HKU\Temp\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaverIsSecure /d "1" /f>Nul

REM Don't show window contents when dragging
reg ADD "HKU\Temp\Control Panel\Desktop\DragFullWindows" /v DragFullWindows /d "0" /f>Nul
REM Don't show window minimize/maximize animations
reg ADD "HKU\Temp\Control Panel\Desktop\WindowMetrics" /v MinAnimate /d "0" /f>Nul

REM Disable Logon Screensaver
reg ADD "HKU\Temp\Control Panel\Desktop" /v ScreenSaveActive /t REG_DWORD /d 1 /f>Nul
REM Disable font smoothing
reg ADD "HKU\Temp\Control Panel\Desktop" /v FontSmoothing /d "0" /f>Nul

REM Disable First Run Server Manager
reg ADD "HKU\Temp\Software\Microsoft\ServerManager" /v DoNotOpenServerManagerAtLogon /t REG_DWORD /d 1 /f>Nul

REM Disable Preview Desktop
reg ADD "HKU\Temp\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v DisablePreviewDesktop /t REG_DWORD /d 1 /f>Nul
REM Start Menu AdmininstrativeTools
reg ADD "HKU\Temp\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v StartMenuAdminTools /t REG_DWORD /d 1 /f>Nul
REM enable file extentions in Explorer
reg ADD "HKU\Temp\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f>Nul

REM Purge Cache for IE on every close of IE
reg ADD "HKU\Temp\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache" /v Persistent /t REG_DWORD /d 0 /f>Nul

reg UNLOAD "HKU\Temp">Nul

REM Disable Creation of Crash Dump
reg ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 0 /f>Nul

REM Default User Account Picture
reg ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v UseDefaultTile /t REG_DWORD /d 1 /f>Nul

REM Show Computer Icon on Desktop
reg ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f>Nul
REM Show Network Icon on Desktop
reg ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f>Nul

REM Disable New Network dialog
reg ADD "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Network\NewNetworkWindowOff">Nul

REM Disable TCP Offload
reg ADD "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v DisableTaskOffload /t REG_DWORD /d 1 /f>Nul

REM Increase Service Startup Timeouts
reg ADD "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control" /v ServicesPipeTimeout /t REG_DWORD /d 180000 /f>Nul

REM Increase Disk I/O Timeout
reg ADD "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Disk" /v TimeOutValue /t REG_DWORD /d 200 /f>Nul

REM disable UAC for vagrant
reg ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /d 0 /t REG_DWORD /f /reg:64>Nul
reg ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
