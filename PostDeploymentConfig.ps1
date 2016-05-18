Configuration PostDeploymentConfig
{

    param
    (
        [Parameter(Mandatory)]
        [String[]]$Disks,
        [Int]$RetryCount=3,
        [Int]$RetryIntervalSec=30,
        [Int]$Counts=2
    )

    Import-DSCResource -ModuleName xStorage
    
    $MyDisk = $Disks
    
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

            foreach($Disk in $MyDisks)
            {

                xWaitforDisk Disk

                {

                DiskNumber = $i
                RetryIntervalSec = $RetryIntervalSec
                Count = $RetryCount

                }

                xDisk FVolume

                {

                DiskNumber = $i
                DriveLetter = $Disk
                FSLabel = ‘Data’

                }
                $Counts++
            }

            }
            TestScript = { $false }
            GetScript = { @{ Result = "" } }
        }
    }
}