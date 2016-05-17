$labels = @("data1,data2")

    $disks = Get-Disk |   Where partitionstyle -eq 'raw' | sort number
 
    ## start at F: because sometimes E: shows up as a CD drive in Azure 
    $letters = 70..89 | ForEach-Object { ([char]$_) }
    $count = 0
 
    foreach($d in $disks) {
        $driveLetter = $letters[$count].ToString()
        $d | 
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $driveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] `
            -Confirm:$false -Force 
        $count++
    }
