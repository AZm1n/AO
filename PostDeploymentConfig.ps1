    param
    (
        [Parameter(Mandatory)]
        [String]$Letters
    )

h


$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
## start at Letters: because sometimes E: shows up as a CD drive in Azure 
[string[]]$Letters = $Letters.Replace("'","").Split(",") #converting the single string into an array of strings

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
