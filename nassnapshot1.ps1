#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$conn="DSMDC"
$FsClusterName = "nas-fs86-prd-1"
$FsCluster = Get-DellFluidFsCluster -ConnectionName $conn -InstanceName $FsClusterName
foreach ( $NasVolume  in  Get-DellFluidFsNasVolume -ConnectionName $conn -ClusterId $FsCluster.InstanceId ) {
    $ScheduleList = @( Get-DellFluidFsSnapshotSchedule -ConnectionName $conn -ClusterId $FsCluster.InstanceId `
    -NasVolumeId $NasVolume.NasVolumeId )
    if ( $ScheduleList.Count -ge 1 )
    {
        $SnapshotName=Get-Date -Format yyyy_MM_dd__hh_mm
        $snapshotName='Daily_'+$SnapshotName
        $ExpirationDate=( Get-Date ).AddDays( 7 )
        $Snapshot = New-DellFluidFsSnapshot -ConnectionName $conn -ClusterId $FsCluster.InstanceId -NasVolumeId $NasVolume.NasVolumeId `
        -Name $SnapshotName -Expiration $ExpirationDate -ExpirationEnabled:$true
    }
}