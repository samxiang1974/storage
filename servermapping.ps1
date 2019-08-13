Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
# Assign variables
$ConnName = "DSMDC"
$ScName = "cmpl-sc8k-blk-prd-1"
$ServerName = "hrv15-app-dev-2"
$ServerFolderPath = "/"
# Get the server
$Server = Get-DellScServer -ConnectionName $ConnName -ScName $ScName -Name $ServerName
# Get the volume mappings
$MappingList = @( Get-DellScMappingProfile -ConnectionName $ConnName `
-Server $Server )
# Get the servers
$VolumeList = @()
ForEach( $Mapping in $MappingList )
{
$VolumeList += @( Get-DellScVolume -ConnectionName $ConnName `
-Instance $Mapping.Volume )
}
# Display the server and volume name
$VolumeList | Sort-Object Name `
| Select-Object @{ Name="LUN UUID"; Expression={ $_.Deviceid } },@{ Name="Volume Name"; Expression={ $_.Name } },@{ Name="Volume Size"; Expression={ $_.ConfiguredSize } }