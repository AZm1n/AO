Configuration PostDeploymentConfig
{

    param
    (
        [Parameter(Mandatory)]
        [String[]]$Disks,
        [Int]$RetryCount=3,
        [Int]$RetryIntervalSec=30,
<<<<<<< HEAD
        [Int]$i=2
    )

=======
        [Int]$Counts=2
    )

    Import-DscResource -ModuleName xComputerManagement,CDisk,XDisk,xNetworkin
   
       
>>>>>>> dfc220d84a6ed24917e4ec643d30936b23282c02
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
<<<<<<< HEAD
                $Disks.ForEach({
                
                $count = 2
                
                    $driveLetter = $_
                    
                    Initialize-Disk -Number $count  -PartitionStyle MBR -PassThru |
                    New-Partition -UseMaximumSize -DriveLetter $driveLetter |
                    Format-Volume -FileSystem NTFS -Confirm:$false -Force 
                    $count++
                               })
=======

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

>>>>>>> dfc220d84a6ed24917e4ec643d30936b23282c02
            }
            TestScript = { $false }
            GetScript = { @{ Result = "" } }
        }
    }
}