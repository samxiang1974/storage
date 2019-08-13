Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$conn="DSMDC" 
$sc=Get-DellStorageCenter -Connectionname $conn |Select-Object Name
foreach ( $scname in $sc ) {
    import-csv "c:\vollist.txt"|foreach {
#    $uuid=$_.UUID.Substring(4,32)
$uuid=$_.UUID
        $ScVolume = Get-DellScVolume -Connectionname $conn -ScName $scname.Name -DeviceId $uuid
        if ( $ScVolume )
        {
          Write-Host $scvolume.Name,$uuid,$scname.Name
          
        }
    }
 }