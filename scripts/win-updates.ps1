#requires -Version 3 -Modules NetSecurity
param(
    $global:RestartRequired = 0,
    $global:MoreUpdates = 0,
    $global:MaxCycles = 5
)

function Use-RunAs
{
    param([Switch]$Check)

    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()`
    ).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')

    if ($Check)
    {
        return $IsAdmin
    }

    if ($script:ScriptFullPath -ne '')
    {
        if (-not $IsAdmin)
        {
            try
            {
                $arg = "-file `"$script:ScriptFullPath`""
                Start-Process -FilePath "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg -ErrorAction 'stop'
            }
            catch
            {
                Write-Warning -Message 'Error - Failed to restart script with runas'
                break
            }
            exit
        }
    }
}

function Configure-Winrm
{
    Write-Output -InputObject 'Enabling WINRM-HTTP Firewallrule'
    Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
    Enable-WSManCredSSP -Force -Role Server

    Write-Output -InputObject 'Configure WINRM Service'
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    winrm.cmd set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm.cmd set winrm/config/client/auth '@{Basic="true"}'
    winrm.cmd set winrm/config/service/auth '@{Basic="true"}'
    winrm.cmd set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm.cmd set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
}

function Check-ContinueRestartOrEnd()
{
    $RegistryKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    $RegistryEntry = 'InstallWindowsUpdates'
    switch ($global:RestartRequired) {
        0
        {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if ($prop)
            {
                Write-Output -InputObject 'Restart Registry Entry Exists - Removing It'
                Remove-ItemProperty -Path $RegistryKey -Name $RegistryEntry -ErrorAction SilentlyContinue
            }

            Write-Output -InputObject 'No Restart Required'
            Check-WindowsUpdates

            if (($global:MoreUpdates -eq 1) -and ($script:Cycles -le $global:MaxCycles))
            {
                Install-WindowsUpdates
            }
            elseif ($script:Cycles -gt $global:MaxCycles)
            {
                Write-Output -InputObject 'Exceeded Cycle Count - Stopping'
            }
            else
            {
                Write-Output -InputObject 'Done Installing Windows Updates'
            }
        }
        1
        {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if (-not $prop)
            {
                Write-Output -InputObject 'Restart Registry Entry Does Not Exist - Creating It'
                Set-ItemProperty -Path $RegistryKey -Name $RegistryEntry -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File $($script:ScriptPath)"
            }
            else
            {
                Write-Output -InputObject 'Restart Registry Entry Exists Already'
            }

            Write-Output -InputObject 'Restart Required - Restarting...'
            Restart-Computer
        }
        default
        {
            Write-Output -InputObject 'Unsure If A Restart Is Required'
            break
        }
    }
}

function Install-WindowsUpdates()
{
    $script:Cycles++
    Write-Output -InputObject 'Evaluating Available Updates:'
    $UpdatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    foreach ($Update in $SearchResult.Updates)
    {
        if (($Update -ne $null) -and (!$Update.IsDownloaded))
        {
            [bool]$addThisUpdate = $false
            if ($Update.InstallationBehavior.CanRequestUserInput)
            {
                Write-Output -InputObject "> Skipping: $($Update.Title) because it requires user input"
            }
            else
            {
                if (!($Update.EulaAccepted))
                {
                    Write-Output -InputObject "> Note: $($Update.Title) has a license agreement that must be accepted. Accepting the license."
                    $Update.AcceptEula()
                    [bool]$addThisUpdate = $true
                }
                else
                {
                    [bool]$addThisUpdate = $true
                }
            }

            if ([bool]$addThisUpdate)
            {
                Write-Output -InputObject "Adding: $($Update.Title)"
                $null = $UpdatesToDownload.Add($Update)
            }
        }
    }

    if ($UpdatesToDownload.Count -eq 0)
    {
        Write-Output -InputObject 'No Updates To Download...'
    }
    else
    {
        Write-Output -InputObject 'Downloading Updates...'
        $Downloader = $UpdateSession.CreateUpdateDownloader()
        $Downloader.Updates = $UpdatesToDownload
        $Downloader.Download()
    }

    $UpdatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    [bool]$rebootMayBeRequired = $false
    Write-Output -InputObject 'The following updates are downloaded and ready to be installed:'
    foreach ($Update in $SearchResult.Updates)
    {
        if (($Update.IsDownloaded))
        {
            Write-Output -InputObject "> $($Update.Title)"
            $null = $UpdatesToInstall.Add($Update)

            if ($Update.InstallationBehavior.RebootBehavior -gt 0)
            {
                [bool]$rebootMayBeRequired = $true
            }
        }
    }

    if ($UpdatesToInstall.Count -eq 0)
    {
        Write-Output -InputObject 'No updates available to install...'
        $global:MoreUpdates = 0
        $global:RestartRequired = 0
        break
    }

    if ($rebootMayBeRequired)
    {
        Write-Output -InputObject 'These updates may require a reboot'
        $global:RestartRequired = 1
    }

    Write-Output -InputObject 'Installing updates...'

    $Installer = $script:UpdateSession.CreateUpdateInstaller()
    $Installer.Updates = $UpdatesToInstall
    $InstallationResult = $Installer.Install()

    Write-Output -InputObject "Installation Result: $($InstallationResult.ResultCode)"
    Write-Output -InputObject "Reboot Required: $($InstallationResult.RebootRequired)"
    Write-Output -InputObject 'Listing of updates installed and individual installation results:'
    if ($InstallationResult.RebootRequired)
    {
        $global:RestartRequired = 1
    }
    else
    {
        $global:RestartRequired = 0
    }

    for($i = 0; $i -lt $UpdatesToInstall.Count; $i++)
    {
        New-Object -TypeName PSObject -Property @{
            Title  = $UpdatesToInstall.Item($i).Title
            Result = $InstallationResult.GetUpdateResult($i).ResultCode
        }
    }

    Check-ContinueRestartOrEnd
}

function Check-WindowsUpdates()
{
    Write-Output -InputObject 'Checking For Windows Updates'
    $Username = $env:USERDOMAIN + '\' + $env:USERNAME

    New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue

    $Message = 'Script: ' + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()

    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventId '104' -EntryType 'Information' -Message $Message
    Write-Output -InputObject $Message

    $script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
    $script:SearchResult = $script:UpdateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
    if ($SearchResult.Updates.Count -ne 0)
    {
        $script:SearchResult.Updates |
        Select-Object -Property Title, Description, SupportUrl, UninstallationNotes, RebootRequired, EulaAccepted |
        Format-List
        $global:MoreUpdates = 1
    }
    else
    {
        Write-Output -InputObject 'There are no applicable updates'
        $global:RestartRequired = 0
        $global:MoreUpdates = 0
    }
}

$script:ScriptName = $MyInvocation.MyCommand.ToString()
$script:ScriptPath = $MyInvocation.MyCommand.Path
$script:ScriptFullPath = $MyInvocation.ScriptName
$script:UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
$script:UpdateSession.ClientApplicationID = 'Packer Windows Update Installer'
$script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
$script:SearchResult = New-Object -ComObject 'Microsoft.Update.UpdateColl'
$script:Cycles = 0

Use-RunAs

Check-WindowsUpdates
if ($global:MoreUpdates -eq 1)
{
    #Install-WindowsUpdates
}
else
{
    Check-ContinueRestartOrEnd
}

Configure-Winrm
