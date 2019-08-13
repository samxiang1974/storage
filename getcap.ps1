#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au
Get-Content "C:\Users\samxiang_admin\Downloads\vollist.txt"|foreach { $totalsize=0 } {
$vol=Get-DellScVolume -Connection $conn -scname "cmpl-sc8k-blk-prd-2" -DeviceId $_
$cap=Get-DellScVolumeStorageUsage -Connection $conn -Instance $vol.InstanceId|Select-Object ActualSpace
$totalsize+=$cap.ActualSpace.GetByteSize()
Write-Host $vol.name
}
Write-host ($totalsize/1tb)