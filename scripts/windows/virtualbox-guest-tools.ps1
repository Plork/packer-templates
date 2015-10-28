$packageName = 'VBoxGuestAdditions'
certutil.exe -addstore -f 'TrustedPublisher' A:\oracle-cert.cer
$url = 'http://download.virtualbox.org/virtualbox/5.0.6/VBoxGuestAdditions_5.0.6.iso'

$unzip = Join-Path $env:TEMP VBoxGuestAdditions
New-Item -Path $unzip -ItemType Directory -Force | Out-Null

$tempDir = Join-Path $env:TEMP "chocolatey\$packageName"
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
$fileFullPath = Join-Path $tempDir "$packageName.iso"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url,$fileFullPath)

$7zip = "$($env:ProgramFiles)\7-Zip\7z.exe"
$process = Start-Process $7zip -ArgumentList "x -o`"$unzip`" -y `"$fileFullPath`"" -Wait -WindowStyle Hidden -PassThru
try { if (!($process.HasExited)) { Wait-Process $process } } catch { }

Set-Location $unzip
Push-Location
$filename = $(Get-ChildItem .\VBoxWindowsAdditions.exe).FullName
try
{
  $process = Start-Process $filename -ArgumentList "/S" -Wait -WindowStyle Hidden -PassThru
  try { if (!($process.HasExited)) { Wait-Process $process } } catch { }
}
catch
{
    write-Error $Error[0]
}
