Write-Output -InputObject 'Reduce PageFile size'
$System = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
$System.AutomaticManagedPagefile = $False
$null = $System.Put()

$CurrentPageFile = Get-WmiObject -Query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
$CurrentPageFile.InitialSize = 512
$CurrentPageFile.MaximumSize = 512
$null = $CurrentPageFile.Put()

Write-Output -InputObject 'Removing unused Windows features'
Remove-WindowsFeature -Name 'Powershell-ISE'
Get-WindowsFeature |
Where-Object -FilterScript {
    $_.InstallState -eq 'Available'
} |
Uninstall-WindowsFeature -Remove

Write-Output -InputObject 'Cleanup update uninstallers'
$null = Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1

Write-Output -InputObject 'Remove logs and temp before Sysprep'
@(
    "$env:localappdata\Nuget",
    "$env:localappdata\temp\*",
    "$env:windir\logs",
    "$env:windir\panther",
    "$env:windir\temp\*",
    "$env:windir\winsxs\manifestcache"
) | ForEach-Object -Process {
    if(Test-Path $_)
    {
        takeown.exe /d Y /R /f $_
        $null = icacls.exe $_ /GRANT:r administrators:F /T /c /q  2>&1
        $null = Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Output -InputObject '0ing out empty space'
Invoke-WebRequest -Uri http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
[System.IO.Compression.ZipFile]::ExtractToDirectory('sdelete.zip', '.')

./sdelete.exe /accepteula -z c:

Write-Output -InputObject 'Copying unattend for sysprep'
$null = mkdir -Path C:\Windows\Panther\Unattend
$null = Copy-Item -Path a:\postunattend.xml -Destination C:\Windows\Panther\Unattend\unattend.xml
