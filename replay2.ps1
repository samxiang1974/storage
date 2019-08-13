#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
$conn="DSMDC"
$ExpireTimeMax = [datetime]"02/17/2018 05:30:00PM"
Get-DellScVolume -ConnectionName $conn -scname "cmpl-sc9k-blk-prd-3"  |foreach { 
$replays=Get-DellScReplay -ConnectionName $conn -CreateVolume $_  -Active:$false
foreach ( $rep in $replays)
{
    if ( $rep.ExpireTime -gt $ExpireTimeMax )
    {
        Write-Host $rep.CreateVolume
      $NewExpireTime = ( Get-Date ).AddDays( 1 )
      Set-DellScReplay -ConnectionName $conn -Instance $rep -ExpireTime $NewExpireTime -Confirm:$false
    }
}
}