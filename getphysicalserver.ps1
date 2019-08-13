#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$conn="DSMDC"
echo "CML,Server,OS,PortType,PathCount">physcial.csv
Get-DellStorageCenter -ConnectionName $conn |Select-Object Name|foreach {
    $scname=$_.Name
    Get-DellScServer -ConnectionName $conn -ScName $scname -Connectivity Up -Type Physical|Where-Object { $_.Operatingsystem -notmatch "Compellent" -and $_.Operatingsystem -notmatch "VMware" }|foreach {
    $_.ScName, $_.name,$_.Operatingsystem.InstanceName,$_.porttype.Name,$_.pathcount -join ','|Out-File -FilePath physcial.csv  -Append
    }
}