Configuration PostDeploymentConfig
{

    param
    (
        [Parameter(Mandatory)]
        [String[]]$Disks,
        [Int]$RetryCount=3,
        [Int]$RetryIntervalSec=30,
        [Int]$i=2
    )

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
                $Disks.ForEach({
                
                $count = 2
                
                    $driveLetter = $_
                    
                    Initialize-Disk -Number $count  -PartitionStyle MBR -PassThru |
                    New-Partition -UseMaximumSize -DriveLetter $driveLetter |
                    Format-Volume -FileSystem NTFS -Confirm:$false -Force 
                    $count++
                               })
            }
            TestScript = { $false }
            GetScript = { @{ Result = "" } }
        }
    }
}
