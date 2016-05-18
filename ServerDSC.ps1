configuration ServerDsc
{
    param
    (
        [Parameter(Mandatory)]
        [String[]]$Disks = $null,
        [Int]$RetryCount=3,
        [Int]$RetryIntervalSec=30
    )

      Import-DscResource -ModuleName xComputerManagement,CDisk,XDisk,xNetworking
  

    Node localhost
    {
    
         xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
        }

        cDiskNoRestart DataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
        }

        xWaitforDisk Disk3
        {
             DiskNumber = 3
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
        }

        cDiskNoRestart LogDisk
        {
            DiskNumber = 3
            DriveLetter = "G"
        }
   
    }

    
}