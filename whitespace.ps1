#import-module "D:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
# Assign variables
#$DatacenterName = "S01 Global Switch"
$vollist=@() 
$conn="DSMDC" 
$vc="mgmt-vc-pro-1.shared.sydney.edu.au"
 Connect-VIServer -Server $vc
# Get the datacenter
$Datacenter = Get-Datacenter
# Get the datastore
Get-Datastore -Server $vc|Select @{N="Name";E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName.Substring(4)}},@{N=”UsedSpaceGB”;E={[Math]::Round(($_.ExtensionData.Summary.Capacity – $_.ExtensionData.Summary.FreeSpace)/1GB,0)}} `
| Export-Csv c:\datastorereport.csv -NoTypeInformation
 Disconnect-VIServer -Server $vc -Confirm:$false
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au -User Admin
$sc=Get-DellStorageCenter -Connectionname $conn |Select-Object Name
foreach( $scname in $sc ) {
    import-csv "c:\datastorereport.csv"|foreach {
        $ScVolume = Get-DellScVolume  -Connectionname $conn -ScName $scname.Name -DeviceId $_.Name
        if ( $ScVolume )
        {
            $cap=Get-DellScVolumeStorageUsage -Connectionname $conn -Instance $ScVolume.InstanceId|Select-Object ActiveSpace
            $dead=$cap.ActiveSpace.GetByteSize()/1gb-[int]$($_.UsedSpaceGB)
            $over=
            if ($dead -ge 1024 )
            {
               Write-Host -Separator ":" $ScVolume.Name,$cap.ActiveSpace,$_.UsedSpaceGB
           }
        }
    }
 }