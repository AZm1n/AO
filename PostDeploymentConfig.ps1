Configuration PostDeploymentConfig
{
    Node localhost
    {
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
 
        Script FormatDataDisk
        {
            SetScript = 
            { 


                $disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
 
                 ## start at F: because sometimes E: shows up as a CD drive in Azure 
                $letters = 70..89 | ForEach-Object { ([char]$_) }
                $count = 0
 
                foreach($d in $disks) {
                    $driveLetter = $letters[$count].ToString()
                    $d | 
                    Initialize-Disk -PartitionStyle MBR -PassThru |
                    New-Partition -UseMaximumSize -DriveLetter $driveLetter |
                    Format-Volume -FileSystem NTFS `
                        -Confirm:$false -Force 
                    $count++
                                    }

                
            }
            TestScript = { $false }
            GetScript = { @{ Result = "" } }
        }
    }
}
