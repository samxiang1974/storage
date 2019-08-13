Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
# Assign variables
$ConnName = "DSMDC"
foreach ($ScName in @("cmpl-sc9k-blk-prd-3","cmpl-sc8k-blk-prd-1"))
{
    $ssh=Get-DellScSshSettings -ConnectionName $ConnName -ScName $Scname
    $ssh=Set-DellScSshSettings -ConnectionName $ConnName -Instance $ssh -SessionTimeToLive 1380 -Confirm:$false
    $ret=Restart-DellScSshSettings -ConnectionName "DSMDC" -Instance $ssh -Confirm:$false
    if ( ! $ret )
    {
        send-mailmessage -from "EnterpriseManager@sydney.edu.au" -to "ict-san-alerts@sydney.edu.au" -subject "Secure Console for $ScName failed to be restarted" `
         -smtpServer smtp.usyd.edu.au
     }
}