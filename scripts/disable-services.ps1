# Disable Application Layer Gateway Service
set-service 'ALG' -startuptype "disabled"

# Disable Device Association Service
set-service 'DeviceAssociationService' -startuptype "disabled"

# Disable Device Setup Manager Service
set-service 'DsmSvc' -startuptype "disabled"

# Disable Diagnostic Policy Services
Set-Service 'DPS' -startuptype "disabled"

# Disable Diagnostic Policy Service
Set-Service 'WdiServiceHost' -startuptype "disabled"

# Disable Diagnostic Policy Service
Set-Service 'WdiSystemHost' -startuptype "disabled"

# Stop Distributed Link Tracking Client Service
Stop-Service 'TrkWks'

# Disable Distributed Link Tracking Client Service
Set-Service 'TrkWks' -startuptype "disabled"

# Disable Function Discovery Resource Publication Service
Set-Service 'FDResPub' -startuptype "disabled"

# Disable Microsoft iSCSI Initiator
Set-Service 'MSiSCSI' -startuptype "disabled"

# Disable Shell Hardware Detection Service
Set-Service 'ShellHWDetection' -startuptype "disabled"

# Disable Secure Socket Tunneling Protocol Service
Set-Service 'SstpSvc' -startuptype "disabled"

# Disable SSDP Discovery
Set-Service 'SSDPSRV' -startuptype "disabled"

# Disable SSDP Discovery
Set-Service 'SSDPSRV' -startuptype "disabled"

# Disable Telephony Service
Set-Service 'TapiSrv' -startuptype "disabled"

# Disable Universal PnP Host Service
Set-Service 'upnphost' -startuptype "disabled"

# Disable Windows Error Reporting Se
Set-Service 'WerSvc' -startuptype "disabled"
