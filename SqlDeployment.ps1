    param
    (
        [String]$Letters,
        [String]$AdminGroup,
        [string]$SxsSource,
        [string]$IpakServer,
        [string]$SqlAdmins
        
    )


#Unmount CD/DVD drive d:
mountvol E: /D

[string[]]$Letters = $Letters.Replace("'","").Split(",") #converting the single string into an array of strings

$count = 0


foreach ($disk in get-wmiobject Win32_DiskDrive -Filter "Partitions = 0"){
$driveLetter = $Letters[$count].ToString()

   $disk.DeviceID
   $disk.Index
   "select disk "+$disk.Index+"`r clean`r create partition primary`r format fs=ntfs unit=65536 quick`r active`r assign letter=$driveLetter" | diskpart
	$count++
}

#Set the time zone
TZUTIL /s "Pacific Standard Time"

#Add group to local administrators group.
net localgroup Administrators /add $AdminGroup

#Create SQL Directories

md H:\MSSQL\DATA
md O:\MSSQL\DATA
md E:\MSSQL\BAK


#Install SQL Framework Core
Install-WindowsFeature Net-Framework-Core -source $SxsSource


$CMD = "/SQL /BIN:C: /DAT:H: /TRAN:O: /BAK:E: /TEMP:D: /QFE:12.0.4422 /RemoveBuiltin /SQLADMIN:REDMOND\PSITADM;"+$AdminGroup+";REDMOND\KE967 /AUTOTEMPFILES /CLEANMSDB /NOLOGCOPY"
#Map Net Drive
net use z: $IpakServer

#Construct the commandline argument
$sqlcmd = "z:\SQL2014SP1\sqlipak.exe"
&$sqlcmd /SQL /BIN:C: /DAT:H: /TRAN:O: /BAK:E: /TEMP:D: /QFE:12.0.4422 /RemoveBuiltin "$SqlAdmins" /AUTOTEMPFILES /CLEANMSDB /NOLOGCOPY

#Add SQL startup Script
md C:\SQLStartup
Copy-Item -Path $SxsSource\SQL-Startup.ps1 -Destination C:\SQLStartup
&C:\SQLStartup\SQL-Startup.ps1

