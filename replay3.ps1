#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
foreach ($sc in Get-DellStorageCenter -ConnectionName "DSMDC" )
{
   Get-DellScReplayProfile -ConnectionName "DSMDC" -ScName $sc.Name|ForEach-Object{
    
    foreach ( $rule in Get-DellScReplayProfileRule -ConnectionName "DSMDC"   -ReplayProfile $_) 
     {
              if ( $rule.Expiration -eq 2400 )
              {
               Set-DellScReplayProfileRule -Instance $rule -ConnectionName "DSMDC" -Expiration 2760
              }
      }
    }
}