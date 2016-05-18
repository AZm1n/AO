configuration ServerDsc
{
    param
    (
        [Parameter(Mandatory)]
        [String[]]$Disks,
        [Int]$RetryCount=3,
        [Int]$RetryIntervalSec=30
    )

      Import-DscResource -ModuleName xComputerManagement,CDisk,XDisk,xNetworking
  
    
    Node localhost
    {
            $i = 2

    foreach($Disk in $Disks)
    {

         xWaitforDisk Disk
        {
             DiskNumber = $i
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
        }

        cDiskNoRestart Disk
        {
            DiskNumber = $i
            DriveLetter = "$Disk"
        }
        $i++
   }

 }

    
}