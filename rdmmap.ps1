#import-module "D:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
# Assign variables
$clustername="S01 MSSQL Cluster"
#$clustername==“S01 Cluster #22 (Windows Failover Cluster)”
# Connect-VIServer -Server "vms-vc-pro-1.mcs.usyd.edu.au"
Connect-VIServer -Server "vcloud-vc-pro-1.shared.sydney.edu.au"
# Get RDM
Get-Cluster $clustername | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select @{N="Name";E={$_.Parent}},@{N="UUID";E={$_.ScsiCanonicalName.Substring(4)}}| `
Export-Csv  C:\C22_VMs_with_RAW_LUN.csv
 
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au -User Admin
$sc=Get-DellStorageCenter -Connection $conn |Select-Object Name
foreach ( $scname in $sc ) {
    import-csv "c:\C22_VMs_with_RAW_LUN.csv"|foreach {
        $ScVolume = Get-DellScVolume -Connection $conn -ScName $scname.Name -DeviceId $_.UUID
        if ( $ScVolume )
        {
          Write-Host $_.Name,$_.UUID,$scname.Name
        }
    }
 }