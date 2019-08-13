Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$ConnName = "DSMDC"
$FsClusterName = "nas-fs86-prd-2"

$FsCluster = Get-DellFluidFsCluster -ConnectionName $ConnName -InstanceName $FsClusterName

foreach ($NasVolume in Get-DellFluidFsNasVolume -ConnectionName $ConnName -ClusterId $FsCluster.InstanceId   `
    -ReplicationStatus "Source" )
{

        Get-DellFluidFsSnapshot -ConnectionName $ConnName -ClusterId $FsCluster.InstanceId -NasVolumeId $NasVolume.NasVolumeId `
        | foreach {
             if ($_.Name -match "daily" -and [int]$_.CreatedOn.dayofweek -ne 2)
            {
            $ExpirationDate=$_.CreatedOn.Adddays(14)
            if ( $ExpirationDate -lt $_.Expiration )
            {
            if($ExpirationDate -le (Get-Date) )
            {
                $ExpirationDate=(Get-Date).Adddays(1)
            }
                Write-Host $_.NasVolumeName,$_.Name
               $Snapshot = Set-DellFluidFsSnapshot -ConnectionName $ConnName `
                  -Instance $_   -Expiration $ExpirationDate
  #              Remove-DellFluidFsSnapshot -ConnectionName $ConnName -Instance $_ -Confirm:$false 
            }
        }
   }
}