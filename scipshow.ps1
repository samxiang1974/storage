#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$conn="DSMDC"
Get-Dellstoragecenter  -ConnectionName $conn|ForEach-Object {
$scname=$_.Name
$ipaddr=$_.ManagementIp
Write-Host $scname,$ipaddr
Get-DellScController -ScName $scname -ConnectionName $conn|Select-Object ScSerialNumber,ipaddress,bmcipaddress|fl
}