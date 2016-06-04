#
# Copyright="© Microsoft Corporation. All rights reserved."
#

configuration PrepareAlwaysOnSqlServer
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLServicecreds,

        [UInt32]$DatabaseEnginePort = 1433,

        [String]$DomainNetbiosName=(Get-NetBIOSName -DomainName $DomainName),

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
   
    )

    Import-DscResource -Module xSQLServer
    Import-DscResource -Module cSQLConfig

 [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$DomainFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$SQLCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SQLServicecreds.UserName)", $SQLServicecreds.Password)


    Node localhost
    {

        
        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        }

                WindowsFeature "NET"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"

        }

           xSqlServerSetup $env:COMPUTERNAME
           {
               DependsOn = '[WindowsFeature]NET'
               SourcePath = "\\10.220.224.39\dsl\Gold\Microsoft\SQL\SQL2014SP1\SQLBITS\SQL\SP1"
               SetupCredential = $DomainCreds
               InstanceName = $env:COMPUTERNAME
               Features = "SQLENGINE,IS,SSMS,ADV_SSMS"
               SQLSysAdminAccounts = $SQLServicecreds.UserName
               InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
               InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
               InstanceDir = "C:\Program Files\Microsoft SQL Server"
               InstallSQLDataDir = "H:\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLUserDBDir = "O:MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLUserDBLogDir = "O:\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLTempDBDir = "T:\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLTempDBLogDir = "T:\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLBackupDir = "F:\MSSQL11.MSSQLSERVER\MSSQL\Data"
           }

           cPowerPlan ($env:COMPUTERNAME)
           {
               PlanName = "High performance"
           }
           cSQLMemory ($env:COMPUTERNAME)
           {
               DependsOn = ("[xSqlServerSetup]" + $env:COMPUTERNAME)
               Ensure = "Present"
               DynamicAlloc = $false
               MinMemory = "256"
               MaxMemory ="1024"
           }
           cSQLMaxDop($env:COMPUTERNAME)
           {
               DependsOn = ("[xSqlServerSetup]" + $env:COMPUTERNAME)
               Ensure = "Present"
               DynamicAlloc = $true
           }


        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $True
        }

    }
}
function Get-NetBIOSName
{ 
    [OutputType([string])]
    param(
        [string]$DomainName
    )

    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) {
            return $DomainName.Substring(0,15)
        }
        else {
            return $DomainName
        }
    }
}
function WaitForSqlSetup
{
    # Wait for SQL Server Setup to finish before proceeding.
    while ($true)
    {
        try
        {
            Get-ScheduledTaskInfo "\ConfigureSqlImageTasks\RunConfigureImage" -ErrorAction Stop
            Start-Sleep -Seconds 5
        }
        catch
        {
            break
        }
    }
}
