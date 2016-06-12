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

#Set the Time zone
TZUTIL /s "Pacific Standard Time"


#Add group to local administrators group.
[string[]]$Admins = $AdminGroup.Replace("'","").Split(";")

foreach ($Admin in $Admins)
{
net localgroup Administrators /add $Admin
}


 #  param
  #  (
   #     [Parameter(Mandatory)]
    #    [String]$Letters
    #)



#$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
## start at Letters: because sometimes E: shows up as a CD drive in Azure 
#[string[]]$Letters = $Letters.Replace("'","").Split(",") #converting the single string into an array of strings

#$count = 0

#foreach($d in $disks) {
#$driveLetter = $Letters[$count].ToString()
#$d | 
#Initialize-Disk -PartitionStyle MBR -PassThru |
#New-Partition -UseMaximumSize -DriveLetter $driveLetter |
 #                   Format-Volume -FileSystem NTFS `
  #                      -Confirm:$false -Force 
   #                 $count++
                                    #}
