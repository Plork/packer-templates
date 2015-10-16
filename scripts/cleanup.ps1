Write-Output "Reduce PageFile size"
$System = GWMI Win32_ComputerSystem -EnableAllPrivileges
$System.AutomaticManagedPagefile = $False
$result = $System.Put()

$CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
$CurrentPageFile.InitialSize = 512
$CurrentPageFile.MaximumSize = 512
$result = $CurrentPageFile.Put()

Write-Output "Removing unused Windows features"
Remove-WindowsFeature -Name 'Powershell-ISE'
Get-WindowsFeature |
? { $_.InstallState -eq 'Available' } |
Uninstall-WindowsFeature -Remove

Write-Output "Cleanup update uninstallers"
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Output "Remove logs and temp before Sysprep"
@(
    "$env:localappdata\Nuget",
    "$env:localappdata\temp\*",
    "$env:windir\logs",
    "$env:windir\panther",
    "$env:windir\temp\*",
    "$env:windir\winsxs\manifestcache"
) | % {
        if(Test-Path $_) {
            Takeown /d Y /R /f $_
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

Write-Output "0ing out empty space"
wget http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".")

./sdelete.exe /accepteula -z c:

Write-Output "Copying unattend for sysprep"
$result = mkdir C:\Windows\Panther\Unattend
$result = copy-item a:\postunattend.xml C:\Windows\Panther\Unattend\unattend.xml
