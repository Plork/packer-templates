@Echo Optimizing OS features for perfomance
@Echo off
REM Disable Last Access Timestamp
FSUTIL behavior set disablelastaccess 1
REM Optimize cache
FSUTIL behavior set memoryusage 2

REM Power Configuration to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Optimize TCP
netsh interface tcp set global autotuninglevel=highlyrestricted

REM Disable Data Execution Prevention
bcdedit /set nx AlwaysOff
REM Turn on DEP for essential Windows programs
bcdedit.exe /set {current} nx optin

REM Recovery Dump to Small
wmic recoveros set DebugInfoType = 3
REM Automatically Restart on System Failure
wmic recoveros set AutoReboot = True

REM Disable Error Reporting
serverWerOptin /disable

REM Disable Packet and Connections Drop Logs
auditpol /set /subcategory:"Filtering Platform Connection" /success:disable /failure:disable
auditpol /set /subcategory:"Filtering Platform Packet Drop" /success:disable /failure:disable
