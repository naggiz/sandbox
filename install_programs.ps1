# Description: Boxstarter / Chocolatey Script
# Author: Lars H (lars@dr.com)

#---- TEMPORARY ---
Disable-UAC
choco feature enable -n allowGlobalConfirmation

# Initialize reboot log file
$reboot_log = "C:\installation.rbt"
if ( -not (Test-Path $reboot_log) ) { New-Item $reboot_log -type file }
$reboots = Get-Content $reboot_log


# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot


# Basic setup
$section = "BasicSetup"
if(-not ($section -in $reboots)) {
	Update-ExecutionPolicy Unrestricted
	Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar
	# Taskbar Options if you want to change defaults
    # Set-TaskbarOptions `
    # -AlwaysShowIconsOff `
    # -Size Small `
    # -Lock
}
# Basic setup
Update-ExecutionPolicy Unrestricted

Set-WindowsExplorerOptions `
    -EnableShowFullPathInTitleBar `
	-EnableShowHiddenFilesFoldersDrives `
	-EnableShowFileExtensions `
	-DisableOpenFileExplorerToQuickAccess `
	-DisableShowRecentFilesInQuickAccess `
	-DisableShowFrequentFoldersInQuickAccess


# Update Windows and reboot if necessary
Install-WindowsUpdate -AcceptEula -GetUpdatesFromMS
Disable-MicrosoftUpdate

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

# don't need remote differential compression if you never intend to pull from network shares...
Disable-WindowsOptionalFeature -Online -FeatureName MSRDC-Infrastructure -NoRestart

# you don't need Fax & Scan, XPS formats, XPS printing services, or printing to http printers. 
Disable-WindowsOptionalFeature -Online -FeatureName FaxServicesClientPackage -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName Xps-Foundation-Xps-Viewer -NoRestart
# Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName Printing-Foundation-InternetPrinting-Client #-NoRestart

# you are not pulling from shares, you should not expose shares...
Set-service -Name LanmanServer -StartupType Disabled
#print spooler: Dead
Set-service -Name Spooler -StartupType Enabled
# Tablet input: pssh nobody use tablet input. its silly.just write right in onenote
Set-service -Name TabletInputService -StartupType Disabled
# Telephony API is tell-a-phony
Set-service -Name TapiSrv -StartupType Disabled
#geolocation service : u can't find me.
Set-service -Name lfsvc -StartupType Disabled
# ain't no homegroup here.
Set-service -Name HomeGroupProvider -StartupType Disabled
# u do not want ur smartcard cert to propagate to the local cache, do you?
Set-service -Name CertPropsvc -StartupType Disabled
# who needs branchcache?
#Set-service -Name PeerDistSvc -StartupType Disabled
# i don't need to keep links from NTFS file shares across the network - i haz office.
Set-service -Name TrkWks -StartupType Disabled
# i don't use iscsi
Set-service -Name MSISCSI -StartupType Disabled
# why is SNMPTRAP still on windows 10? i mean, really, who uses SNMP? is it even a real protocol anymore?
Set-service -Name SNMPTRAP -StartupType Disabled
# Peer to Peer discovery svcs... Disable
Set-service -Name PNRPAutoReg -StartupType Disabled
Set-service -Name p2pimsvc -StartupType Disabled
Set-service -Name p2psvc -StartupType Disabled
Set-service -Name PNRPsvc -StartupType Disabled
# no netbios over tcp/ip. unnecessary. 
Set-service -Name lmhosts -StartupType Disabled
# Like plug & play only for network devices. Disable
Set-service -Name SSDPSRV -StartupType Disabled
# YOU DO NOT NEED TO PUBLISH FROM THIS DEVICE. Discovery Resource Publication service:
Set-service -Name FDResPub -StartupType Disabled
#"Function Discovery host provides a uniform programmatic interface for enumerating system resources". Disable 
Set-service -Name fdPHost -StartupType Disabled
#optimize the startup cache...i think. on SSD i don't think it really matters.
set-service SysMain -StartupType Automatic

# Privacy: Let apps use my advertising ID: Disable
If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
}
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

# WiFi Sense: HotSpot Sharing: Disable
If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
}
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

# WiFi Sense: Shared HotSpot Auto-Connect: Disable
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

# Start Menu: Disable Bing Search Results
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0
# To Restore (Enabled):
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 1

# Change Explorer home screen back to "This PC"
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1
# Change it back to "Quick Access" (Windows 10 default)
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 2

# Better File Explorer
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# These make "Quick Access" behave much closer to the old "Favorites"
# Disable Quick Access: Recent Files
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0
# Disable Quick Access: Frequent Folders
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0
# To Restore:
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 1
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 1

# Disable the Lock Screen (the one before password prompt - to prevent dropping the first character)
If (-Not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization)) {
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization | Out-Null
}
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1
# To Restore:
# Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1

# Lock screen (not sleep) on lid close
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 1
# To Restore:
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 0

# Use the Windows 7-8.1 Style Volume Mixer
If (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name MTCUVC | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 0
# To Restore (Windows 10 Style Volume Control):
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 1

# Disable Xbox Gamebar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

# Turn off People in Taskbar
# If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    # New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
# }
# Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0


#---LIBRARIES---
# come on, you know you like em, you use em all the time. might as well make sure they come back each and every time, right?
# this assumes you set up onedrive. 
# Move-LibraryDirectory -libraryName "Personal" -newPath $ENV:OneDrive\Documents
# Move-LibraryDirectory -libraryName "My Pictures" -newPath $ENV:OneDrive\Pictures
# Move-LibraryDirectory -libraryName "My Video" -newPath $ENV:OneDrive\Videos
# Move-LibraryDirectory -libraryName "My Music" -newPath $ENV:OneDrive\Music
 

#--- Windows Subsystems/Features ---
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

choco install Microsoft-Hyper-V-All -source windowsFeatures
choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures

if (Test-PendingReboot) { Invoke-Reboot }

# #--- Tools ---
choco install TotalCommander -y
choco install foxitreader -y
# choco install chocolateygui -y
choco install 1password -y
choco install 7zip -y
choco install notepadplusplus -y
choco install putty -y
choco install utorrent
choco install filezilla -y # FTP-server
choco install winscp -y 
choco install imgburn -y
choco install angryip -y # Angry IP-scanner
choco install etcher # Balena etcher (brenne SD-kort)


# # --- DevTools ---
choco install postman
choco install soapui
choco install nodejs.install
choco install yarn
cinst python
cinst pip
cinst easy.install
pip install pytest
pip install math
Pip install simplejson
Pip install requests
pip install libcurl
Pip install pycurl
Pip install plotly
Pip install pyqt # GUI programming

 
choco install curl -y 
choco install anaconda3 -y
choco install ruby-y
choco install php -y 
#choco install visualstudiocode -y
#choco install visualstudio2017community -y  
#choco install visualstudio2017-workload-manageddesktop -y
#choco install virtualbox -y
choco install SourceTree -y 
choco install mongodb -y
#choco install docker-for-windows -y 
choco install git -params '"/GitAndUnixToolsOnPath /WindowsTerminal"' -y


# # --- Git ---
Write-Verbose "Install Git"
choco install poshgit
Import-Module posh-git
choco upgrade git
refreshenv
git config --global user.name "Lars Hjornevik"
git config --global user.email "lars@dr.com"
git config --global credential.helper wincred
git config --global --bool pull.rebase true



# # --- Communication ---
choco install discord
#choco install skype -y 
#choco install whatsapp -y 
choco install signal -y


# # --- Media and office ---
choco install spotify -y
#choco install itunes -y
choco install vlc -y
choco install exiftool -y  # Meta data program
choco install sharex -y  # Screen capture software, ranked 1
#choco install greenshot -y  # Screen capture software, ranked 2
choco install IrfanView -y 
choco install irfanviewplugins -y 
choco install k-litecodepackfull -y 
choco install AudaCity -y # Record and edit sounds
choco install -y flashplayerplugin
choco install paint.net -y 
#choko install libreoffice-fresh -y
choco install uplay
choco install adobereader
choco install pdf-ifilter-64 # Adobe PDF iFilter allows the user to easily search for text within Adobe PDF documents using Microsoft indexing clients.
choco install calibre -y # Ebok



# # --- Apps ---
choco install brave -y
choco install googlechrome -y
choco install tor-browser -y
choco install Openvpn -y
#choco install thunderbird -y
choco install evernote -y



# # --- Games ---
choco install dosbox
choco install fs-uae
choco install freeciv -y
#choco install steam -y
choco install steamcmd -y  # https://developer.valvesoftware.com/wiki/SteamCMD
choco install steam-cleaner # Steam Cleaner is a tool that will remove large amounts of data left behind by Steam, Origin, Uplay and GoG.
#choco install epicgameslauncher


# #--- Fonts ---
choco install inconsolata -y
choco install sourcecodepro -y
