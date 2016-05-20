    param
    (
        [Parameter(Mandatory)]
        [String[]]$Letters
    )


$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
## start at F: because sometimes E: shows up as a CD drive in Azure 
$count = 0
foreach($d in $disks) {
$driveLetter = $Letters[$count].ToString()
$d | 
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -UseMaximumSize -DriveLetter $driveLetter |
                    Format-Volume -FileSystem NTFS `
                        -Confirm:$false -Force 
                    $count++
                                    }
