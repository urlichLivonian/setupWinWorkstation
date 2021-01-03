#Отключить к хуям параною йобанного эксплорера


#Show hidden files
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0

Stop-Process -processname explorer

#optional
Set-ItemProperty $key ShowSuperHidden 1


Install-Module PSWindowsUpdate
<#
So, when trying to connect to the RemoteApp on RDS servers running Windows Server 2016/2012 R2/2008 R2, or to remote desktops of other users using the RDP protocol (on Windows 10, 8.1 or 7), an error appears:
Change update settings
Available Notification Levels:
1 - Never check for updates"
2 - Check for updates but let me choose whether to download and install them"
3 - Download updates but let me choose whether to install them"
4 - Install updates automatically
#>
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name AUOptions -Value 3

$UpdateSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$UpdateSettings.NotificationLevel=3
$UpdateSettings.save()

Get-WindowsUpdate
Install-WindowsUpdate