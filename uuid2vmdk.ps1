#import-module "D:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
#Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
# Assign variables
$DatacenterName = "S01 Global Switch"
$uuid=@("6000d31000744400000000000000043b")
Connect-VIServer -Server "vms-vc-pro-1.mcs.usyd.edu.au"
# Get the datacenter
$Datacenter = Get-Datacenter -Name $DatacenterName
# Get the canonical name of the datastore
# Add "naa." to the Storage Center volume device ID
for ( $i=0; $i -lt $uuid.Length;$i++ )
{
    $uuid[$i] = "naa." + $uuid[$i]
}
# Get the datastore
Get-Datastore -Location $Datacenter|Where-Object { $uuid -contains $_.ExtensionData.Info.Vmfs.Extent[0].DiskName }| `
Get-HardDisk|select @{N="Name";E={($_.filename.split('/'))[0]}},@{N="CapacityGB";E={$_.capacitygb}}|ft -AutoSize

Disconnect-VIServer -Server "vms-vc-pro-1.mcs.usyd.edu.au" -Confirm:$false