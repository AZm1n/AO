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

    Import-DscResource -ModuleName xComputerManagement,CDisk,XDisk,xNetworkin
   
       
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

                cDiskNoRestart Disk

                {

                DiskNumber = $Counts
                DriveLetter = $_
                
                }
                $Counts++
            })

            }
            TestScript = { $false }
            GetScript = { @{ Result = "" } }
        }
    }
}