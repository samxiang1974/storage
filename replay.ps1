#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$FreezeTimeMin = [datetime]"04/05/2017 05:00:00PM"
$FreezeTimeMax = [datetime]"04/06/2017 05:30:00PM"
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au
Get-DellScVolume -Connection $conn -scname "cmpl-sc9k-blk-prd-3" -VolumeFolderPath "bi-app-pro-1/" |foreach { 
$replays=Get-DellScReplay -Connection $conn -CreateVolume $_  -Active:$false
foreach ( $rep in $replays)
{
    if ( $rep.FreezeTime -ge $FreezeTimeMin -and $rep.FreezeTime -le $FreezeTimeMax )
    {
            $NewExpireTime = ( Get-Date ).AddDays( 6 )
        Set-DellScReplay -Connection $conn -Instance $rep -ExpireTime $NewExpireTime -Confirm:$false
    }
}
}
