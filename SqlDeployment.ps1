    param
    (
        [String]$Letters,
        [String]$AdminGroup,
        [string]$SxsSource,
        [string]$IpakServer,
        [string]$SqlAdmins
        
    )


#Unmount CD/DVD drive d:
Write-Host "Unmounting CD/DVD drive"
mountvol E: /D

[string[]]$Letters = $Letters.Replace("'","").Split(",") #converting the single string into an array of strings

$count = 0

Write-Host "Starting Disk format...please wait"

foreach ($disk in get-wmiobject Win32_DiskDrive -Filter "Partitions = 0"){
$driveLetter = $Letters[$count].ToString()

   $disk.DeviceID
   $disk.Index
   "select disk "+$disk.Index+"`r clean`r create partition primary`r format fs=ntfs unit=65536 quick`r active`r assign letter=$driveLetter" | diskpart
	$count++
}

#Set the time zone
Write-Host "Setting up the timezone"
TZUTIL /s "Pacific Standard Time"

#Add group to local administrators group.
[string[]]$Admins = $AdminGroup.Replace("'","").Split(";")

Write-Host "Addint the users to Adminstrators group"
foreach ($Admin in $Admins)
{
net localgroup Administrators /add $Admin
}
#Create SQL Directories

Write-Host "Creating SQL directories"

md H:\MSSQL\DATA
md O:\MSSQL\DATA
md E:\MSSQL\BAK


#Install SQL Framework Core
Write-Host "Installing framework 3.5"
Install-WindowsFeature Net-Framework-Core -source $SxsSource

#Pause for 30 seconds after the framework install
Write-Host "Starting sleeping for 60 seconds"
Start-Sleep -Seconds 60

#Map Net Drive
#net use z: $IpakServer
Write-Host "Mapping networ drive"
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $IpakServer


#Construct the commandline argument
Write-Host "Running the IPAK..."
$sqlcmd = "Z:\SQL2014SP1\sqlipak.exe"
&$sqlcmd /SQL /BIN:C: /DAT:H: /TRAN:O: /BAK:E: /TEMP:D: /QFE:12.0.4422 /RemoveBuiltin "$SqlAdmins" /AUTOTEMPFILES /CLEANMSDB /NOLOGCOPY


#Add SQL startup Script
Write-Host "Adding SQL startup scripts"

md C:\SQLStartup
Copy-Item -Path $SxsSource\SQL-Startup.ps1 -Destination C:\SQLStartup
&C:\SQLStartup\SQL-Startup.ps1

