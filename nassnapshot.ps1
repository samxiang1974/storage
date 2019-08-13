Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$ConnName = "DSMDC"
$FsClusterName = "nas-fs86-dr-2"

$FsCluster = Get-DellFluidFsCluster -ConnectionName $ConnName -InstanceName $FsClusterName

foreach ($NasVolume in Get-DellFluidFsNasVolume -ConnectionName $ConnName -ClusterId $FsCluster.InstanceId  `
    -ReplicationStatus "Destination" )
{

        Get-DellFluidFsSnapshot -ConnectionName $ConnName -ClusterId $FsCluster.InstanceId -NasVolumeId $NasVolume.NasVolumeId |Where-Object {$_.Name -notmatch "Monthly"} `
        | foreach {
            if ($_.Name -match "rep_")
            {
                $ExpirationDate=$_.CreatedOn.AddDays(1)
            }else
            {
                $ExpirationDate=$_.CreatedOn.AddDays(30)
            }
            
            if ( $ExpirationDate -lt (Get-Date) )
            {
                Write-Host $_.NasVolumeName,$_.Name
               Remove-DellFluidFsSnapshot -ConnectionName $ConnName -Instance $_ -Confirm:$false 
            }
        }
}
   
