    param
    (
        [Parameter(Mandatory)]
        [String[]]$Letters
    )


$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
## start at F: because sometimes E: shows up as a CD drive in Azure

$Letters.Split("{,}")

$count = 2
foreach($l in $Letters) {

Initialize-Disk -Number $count -PartitionStyle MBR -PassThru |
New-Partition -UseMaximumSize -DriveLetter $l |
                    Format-Volume -FileSystem NTFS `
                        -Confirm:$false -Force 
                    $count++
                                    }
