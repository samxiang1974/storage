Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au
$conn="DSMDC"
Get-DellScVolume -ConnectionName $conn -scname "cmpl-sc8k-rds-dr-1" |foreach { 
$volconfig=Get-DellScVolumeConfiguration -ConnectionName $conn -Instance $_.InstanceId
if (  $volconfig.StorageProfile.InstanceName -ne "Replications on Flash" )
{
#$Qos=Get-DellScQosProfile -Connection $conn -ScName "cmpl-sc8k-blk-prd-2" -Name "Silver QoS"
$volconfig=Set-DellScVolumeConfiguration -ConnectionName $conn -Instance $volconfig -WriteCacheEnabled $true

}
}
