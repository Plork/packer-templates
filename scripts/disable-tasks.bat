@Echo Disabling unused scheduled tasks
@Echo off
REM Disable Defrag
schtasks /change /tn "\Microsoft\windows\defrag\ScheduledDefrag /disable

REM Disable the Windows Customer Experience Improvement Program
schtasks /change /tn "\Microsoft\windows\Application Experience\AitAgent" /disable
schtasks /change /tn "\Microsoft\windows\Application Experience\ProgramDataUpdater" /disable
schtasks /change /tn "\Microsoft\windows\Customer Experience Improvement Program\Consolidator" /disable
schtasks /change /tn "\Microsoft\windows\Customer Experience Improvement Program\KernelCeipTask" /disable
schtasks /change /tn "\Microsoft\windows\Customer Experience Improvement Program\UsbCeip" /disable

REM Disable Autocheck Proxy
schtasks /change /tn "\Microsoft\windows\Autochk\Proxy" /disable

REM Disable Reliability Analysis
schtasks /change /tn "\Microsoft\windows\RAC\RacTask" /disable

REM Disable Registry Idle Backup
schtasks /change /TN "\Microsoft\Windows\Registry\RegIdleBackup" /Disable

REM Disable Server Manager at startup
schtasks /change /TN "\Microsoft\Windows\Server Manager\ServerManager" /Disable
