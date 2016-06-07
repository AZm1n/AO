    param
    (
        [String]$Letters,
        [String]$AdminGroup
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

#Add group to local administrators group.
net localgroup Administrators /add $AdminGroup

#Create SQL Directories

md H:\MSSQL\DATA
md O:\MSSQL\DATA
md E:\MSSQL\BAK


#Install SQL Framework Core
Install-WindowsFeature Net-Framework-Core -source \\TK5-CU-ADMIN02\img\sources\sxs

#Construct the commandline argument
$CMD = "/SQL /BIN:C: /DAT:H: /TRAN:O: /BAK:E: /TEMP:T: /QFE:12.0.4422 /RemoveBuiltin /SQLADMIN:REDMOND\PSITADM;"+$AdminGroup+";REDMOND\KE967 /AUTOTEMPFILES /CLEANMSDB /NOLOGCOPY"
#Map Net Drive
net use z: \\10.220.224.39\DSL\Gold\Microsoft\SQL
z:

#Switch to IPAK directory
cd SQL2014SP1

$CMD | ./SQLIPAK.Exe
#./SQLIPAK.Exe /SQL /BIN:C: /DAT:H: /TRAN:O: /BAK:E: /TEMP:T: /QFE:12.0.4422 /RemoveBuiltin /SQLADMIN:REDMOND\PSITADM;$AdminGroup;REDMOND\KE967; /AUTOTEMPFILES /CLEANMSDB /NOLOGCOPY /preview
