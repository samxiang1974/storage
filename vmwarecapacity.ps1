#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au
$conn="DSMDC" 
$activesize=0
$actualsize=0
$DC="PRD"
if ($DC -eq "PRD" )
{
    $cml="blk.*prd"
}else
{
    $cml="blk.*dr"
}
Get-DellStorageCenter -Connectionname $conn |where-object { $_.Name -match $cml }|Select-Object Name|foreach {
    $scname=$_.Name
Get-DellScVolumeFolder -ScName $scname -ConnectionName $conn |Where-Object { $_.Name -match "Cluster" -or $_.Name -match "DellPod" -or $_.FolderPath -match "Cluster"}|foreach{ `
$folder=$_
foreach ( $vol in Get-DellScVolume -ConnectionName $conn -scname $scname -VolumeFolder $folder )
{
    $cap=Get-DellScVolumeStorageUsage -ConnectionName $conn  -Instance $vol.InstanceId
    $actualsize+=$cap.ActualSpace.GetByteSize()
    $activesize+=$cap.ActiveSpace.GetByteSize()
}
Write-Host $scname,$folder,($actualsize/1tb)
}
}
Write-host ($actualsize/1tb),($activesize/1tb)