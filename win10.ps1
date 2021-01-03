<#
The OpenSSH client is included in Windows 10 Features on Demand (like RSAT). 
The SSH client is installed by default on Windows Server 2019, Windows 10 1809 and newer builds.
#>

#Check that the SSH client is installed:
Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Client*'

#If not (State: Not Present), you can install it using:
Add-WindowsCapability -Online -Name OpenSSH.Client*

#download file function
function Get-File
{
 param (
 [string]$url,
 [string]$saveAs
 )

Write-Host "Downloading $url to $saveAs"
 $downloader = new-object System.Net.WebClient
 $downloader.DownloadFile($url, $saveAs)
}

#download Windows Remote Server Admin Tool (allows Server Manager Module)
$SaveAsFileName = "$env:TMP\WindowsTH-RSAT_WS2016-x64.msu"
$Uri = "https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-RSAT_WS2016-x64.msu"
Get-File $Uri $SaveAsFileName

# install RSAT
wusa $env:TMP\WindowsTH-RSAT_WS2016-x64.msu /quiet


#Show hidden files
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0

Stop-Process -processname explorer

#optional
Set-ItemProperty $key ShowSuperHidden 1