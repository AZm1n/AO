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
$sqlcmd = "z:\SQL2016\setup.exe"
&$sqlcmd /INDICATEPROGRESS  /IAcceptSQLServerLicenseTerms /INSTANCENAME="MSSQLSERVER" /UpdateEnabled="False" /INSTANCEID="MSSQLSERVER" /ACTION="Install" /FEATURES="SQL,Tools" /INSTALLSHAREDDIR="C:\MSSQL13" /INSTALLSHAREDWOWDIR="C:\MSSQL13 (x86)" /INSTANCEDIR="C:\MSSQL13" /SQLSVCACCOUNT="NT SERVICE\MSSQLSERVER" /AGTSVCACCOUNT= "NT SERVICE\SQLSERVERAGENT" /AGTSVCSTARTUPTYPE="Automatic" /FILESTREAMLEVEL="0" /SQLCOLLATION="SQL_Latin1_General_CP1_CI_AS" /SQLSYSADMINACCOUNTS=$AdminGroup /SQLSVCSTARTUPTYPE="Automatic" /TCPENABLED="1" /NPENABLED="0" /SQLBACKUPDIR="E:\MSSQL13.MSSQLSERVER\MSSQL\Backup" /SQLTEMPDBDIR="D:\MSSQL13.MSSQLSERVER\MSSQL\Data" /SQLTEMPDBLOGDIR="D:\MSSQL13.MSSQLSERVER\MSSQL\Data" /SQLUSERDBDIR="H:\MSSQL13.MSSQLSERVER\MSSQL\Data" /INSTALLSQLDATADIR="H:\\" /SQLUSERDBLOGDIR="O:\MSSQL13.MSSQLSERVER\MSSQL\Data" /BROWSERSVCSTARTUPTYPE="Manual" /ISSVCACCOUNT="NT AUTHORITY\Network Service" /ISSVCSTARTUPTYPE="Automatic"
#Switch to IPAK directory
#cd SQL2014SP1

#$CMD | ./SQLIPAK.Exe
#./SQLIPAK.Exe /SQL /BIN:C: /DAT:H: /TRAN:O: /BAK:E: /TEMP:T: /QFE:12.0.4422 /RemoveBuiltin /SQLADMIN:REDMOND\PSITADM;$AdminGroup;REDMOND\KE967; /AUTOTEMPFILES /CLEANMSDB /NOLOGCOPY /preview
