#>
 
param(
  [Parameter(Mandatory = $true,
                    Position = 0,
                    ValueFromPipelineByPropertyName = $true)]
  [Int]$NotificationLevel,
 
  [Parameter(Mandatory = $false,
                    Position = 1,
                    ValueFromPipelineByPropertyName = $true)]
  [Int]$ScheduledInstallationTime=4,
   
  [Parameter(Mandatory = $false,
                    Position = 2,
                    ValueFromPipelineByPropertyName = $true)]
  [String]$LogFile=""
)
 
[Boolean]$ErrFound = $false
 
Write-Host -NoNewLine ("Microsoft AutoUpdate settings on " + $env:COMPUTERNAME + " after update by this script:")
 
try {
 
  # Set other values using the Microsoft.Update.AutoUpdate COM object
  $objAutoUpdateSettings = (New-Object -ComObject "Microsoft.Update.AutoUpdate").Settings
  $objAutoUpdateSettings.NotificationLevel = $NotificationLevel
  $objAutoUpdateSettings.ScheduledInstallationDay = 0
  $objAutoUpdateSettings.ScheduledInstallationTime = $ScheduledInstallationTime
  $objAutoUpdateSettings.IncludeRecommendedUpdates = $true
  $objAutoUpdateSettings.NonAdministratorsElevated = $true
  $objAutoUpdateSettings.FeaturedUpdatesEnabled = $true
  $objAutoUpdateSettings.save()
 
  $objSysInfo = New-Object -ComObject "Microsoft.Update.SystemInfo"
  $objAutoUpdateSettings
  "Reboot required               : " + $objSysInfo.RebootRequired
 
  # NoAutoReboot can apparently only be set by policy, so set and report that here.
  # Reference: https://technet.microsoft.com/en-us/library/cc720464%28v=ws.10%29.aspx.
  New-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Force | Out-Null
  New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoRebootWithLoggedOnUsers -Value 1 -PropertyType DWORD -Force | Out-Null
  Write-Host -NoNewLine ("NoAutoRebootWithLoggedOnUsers : ")
  try {
    # If Get-ItemProperty fails, value is not in registry. Do not fail entire script. 
    # "-ErrorAction Stop" forces it to catch even a non-terminating error.
    $output = Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoRebootWithLoggedOnUsers -ErrorAction Stop
    switch ($output.NoAutoRebootWithLoggedOnUsers)
    {
      0 {"False (set in registry)"}
      1 {"True (set in registry)"}
    }
  }
  catch { 
    "Unknown (local policy registry value not found)" 
  }
   
  # The rest of this is just static info on the meaning of various Settings.
  ""
  "NotificationLevel:"
  "1 - Never check for updates"
  "2 - Check for updates but let me choose whether to download and install them"
  "3 - Download updates but let me choose whether to install them"
  "4 - Install updates automatically"
  ""
  "ScheduledInstallationDay"
  "0 - Every day"
  "1-7 - Sunday through Saturday"
  "Note:  On Windows 8/2012 and later, ScheduledInstallationDay and"
  "       ScheduledInstallationTime are only reliable if the values" 
  "       are set through Group Policy."
  ""
  "Script execution succeeded"
  $ExitCode = 0
}
catch {
  ""
  $error[0]
  ""
  "Script execution failed"
  $ExitCode = 1001 # Cause script to report failure in GFI dashboard
}
 
""
"Local Machine Time:  " + (Get-Date -Format G)
"Exit Code: " + $ExitCode
Exit $ExitCode