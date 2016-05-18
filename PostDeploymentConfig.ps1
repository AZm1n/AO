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

                xWaitforDisk Disk

                {

                DiskNumber = $Counts
                RetryIntervalSec = $RetryIntervalSec
                Count = $RetryCount

                }

                xDisk FVolume

                {

                DiskNumber = $Counts
                DriveLetter = $_
                FSLabel = ‘Data’

                }
                $Counts++
            })

            }
            TestScript = { $false }
            GetScript = { @{ Result = "" } }
        }
    }
}