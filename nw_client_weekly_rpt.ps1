<#
NetWorker Weekly client DD Report
#>

### vars
$date = Get-Date -Format D
## customer info
$customer="USYD"
$nwsvr="nwdd-s01-1.ucc.usyd.edu.au"
## nmc crdentials
$user="report"
$pwd="Passw0rd!@#"
## where to store report files
$reportstore="c:\NW_Bkup_Reports\"
## mail settings
$smtprelay="smtp.usyd.edu.au"
$smtpport="25"
$from="backupsmaster@sydney.edu.au"
$to="ictplatformservices@sydney.edu.au"
$cc=""
# smtp credentials (if auth is required)
#$smtpuser = "nsrhost@${domain}"
#$smtppwd = "password"
## report gen vars
# note: JAVA_HOME must be set in gstclreport.bat script
$gstclrpt="C:\Program Files\EMC NetWorker\Management\GST\bin\gstclreport.bat"
$rptformat="csv"
$now =  get-date -uformat "%Y-%m-%d_%H-%M-%S"
$rpt="/Reports/Policy Statistics/Client Summary"
$rpttmp="rpttmp"
$htmlout="${reportstore}Client_Smmary_${now}.html"

"Begin Report Script"

if ( (Get-Date).Day -eq 1)
{
    $period="Monthly"
}else
{
    $period="Weekly"
}

try
{

# generate csv report
#write-host "$gstclrpt -u $user -P $pwd -r `"$rpt`" -x $rptformat -o landscape -f `"$reportstore$rpttmp`" -C `"Workflow Start Time`" `"1 Week`" -C `"Server Name`" $nwsvr"
if ( $period -eq "Weekly" )
{
& $gstclrpt -u $user -P $pwd -r `"$rpt`" -x $rptformat -o landscape -f `"$reportstore$rpttmp`" -C `"Workflow Start Time`" `"1 Week`" 
}else
{
& $gstclrpt -u $user -P $pwd -r `"$rpt`" -x $rptformat -o landscape -f `"$reportstore$rpttmp`" -C `"Workflow Start Time`" `"1 month`" 
}
### convert csv to html
# html report format
$title = "$period $nwsvr client DD Report"
$style = @"
<style>
TABLE{border-width: 3px;border-style: solid;border-color: black;border-collapse: collapse;}
TH{border-width: 2px;text-align: center;padding: 10px;border-style: solid;border-color: black;font-family: Arial;color: #FFFFFF;background-color:#08088A}
TD{border-width: 2px;text-align: center;padding: 10px;border-style: solid;border-color: black;font-family: Arial;color: #0A0A2A;background-color: #FAFAFA}
tr.special {background: #000080;} <tr class="special"></tr>
</style>
"@
$rpthead = @"
<font face="Arial"><b>
Customer:  $customer<br>
NetWorker Server:  $nwsvr<br>
Report Date:  $date<br>
</b></font>
"@

#write-host "Get-Content "$reportstore$rpttmp.csv" | select -skip 10 | ConvertFrom-Csv | ConvertTo-Html -head $style | Out-File $htmlout"
$numberStyles = [System.Globalization.NumberStyles];
Get-Content "$reportstore$rpttmp.csv" | select -skip 10 | ConvertFrom-Csv | Sort-Object { [int64]::Parse($_."Target Size (B)",$numberStyles::AllowThousands) } -Descending |ConvertTo-Html -title $title -head $style -body $rpthead | Out-File $htmlout

$subject = " $customer - $period $nwsvr client DD Report - " + $date
$body = (Get-Content $htmlout | out-string)
send-mailmessage -from $from -to $to -subject $subject -body $body -bodyashtml -smtpserver $smtprelay

}

catch [system.exception]
{
"caught a system exception"
}

finally
{
"Report Script Complete"
}