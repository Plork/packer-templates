@echo Settings Registry values

reg ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v HideFileExt /t REG_DWORD /d 0 /f>Nul

reg ADD HKCU\Console /v QuickEdit /t REG_DWORD /d 0 /f>Nul

reg ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v StartMenuAdminTools /t REG_DWORD /d 1 /f>Nul

reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateFileSizePercent /t REG_DWORD /d 0 /f>Nul
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateEnabled /t REG_DWORD /d 0 /f>Nul

reg add HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /d 0 /t REG_DWORD /f /reg:64>Nul
