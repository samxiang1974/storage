Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au
$conn="DSMDC" 
$DC="PRD"
if ($DC -eq "PRD" )
{
    $cml="blk.*prd"
}else
{
    $cml="blk.*dr"
}
echo "VM|CML|Application|profile|OS|GBsize|UsedGB">servercapaicty
Get-DellStorageCenter -Connectionname $conn |where-object { $_.Name -match $cml }|Select-Object Name|foreach {
    $scname=$_.Name
 # Get-DellScServer -ConnectionName $conn -ScName $scname -Connectivity Up |Where-Object { $_.Operatingsystem -notmatch "Compellent" -and $_.Operatingsystem -notmatch "VMware" -and $_.Operatingsystem -notmatch "FluidFS" } `
  Get-DellScServer -ConnectionName $conn -ScName $scname|Where-Object { $_.Operatingsystem -notmatch "Compellent Any"}|foreach {
        $MappingList =Get-DellScMappingProfile -ConnectionName $conn -Server $_
        $cap=Get-DellScServerStorageUsage -Instance $_.InstanceId -ConnectionName $conn
        $os=$_.Operatingsystem.InstanceName
        ForEach( $Mapping in $MappingList )
        {
            if ( $Mapping.Volume -ne $null)
            {
            $ScVolume=Get-DellScVolume -ConnectionName $conn -Instance $Mapping.Volume
            $volconfig=Get-DellScVolumeConfiguration -ConnectionName $conn -Instance $ScVolume.InstanceId
            if( $volconfig.StorageProfile.InstanceName -match "Flash" -or $volconfig.StorageProfile.InstanceName -match "High throughput" )
            {
                $profile="Gold"
            }elseif ($volconfig.ScName -eq "cmpl-sc4k-blk-prd-4")
            {
                $profile="Silver"
            }else{
            
                $profile=$volconfig.StorageProfile.InstanceName
            }
            $cap.InstanceName,$Scname,"Physical",$profile,$os,[int32]($cap.TotalDiskSpace.ByteSize/1gb),[int32]($cap.ActiveSpace.ByteSize/1gb) -join '|'|Out-File -FilePath "servercapaicty" -Append 
            }
        }
   }
 }

 Import-Csv -Delimiter '|' servercapaicty |sort -Unique VM,CML,Application,profile,OS,GBsize,UsedGB|export-csv -Delimiter '|' physicalCap.csv -NoTypeInformation
