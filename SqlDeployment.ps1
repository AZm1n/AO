    param
    (
        [String]$Letters,
        [String]$AdminGroup
    )

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
md F:\MSSQL\BAK

#Map Net Drive
net use z: \\10.220.224.39\DSL\Gold\Microsoft\SQL
z:

#Switch to IPAK directory
cd SQL2014SP1
./SQLIPAK.Exe /SQL /BIN:C: /DAT:H: /TRAN:O: /BAK:F: /TEMP:T: /QFE:12.0.4422 /RemoveBuiltin /SQLADMIN:REDMOND\PSITADM;REDMOND\KE967; /AUTOTEMPFILES /CLEANMSDB /NOLOGCOPY /preview
