import-module "D:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
# Assign variables
$DatacenterName = "S01 Global Switch"
#$DatacenterName ="S01 Global Switch (workload)"
$VM=$null
$vollist=@()
$conn="DSMDC" 
$VMName = Read-Host -Prompt "Please input VM name" 
Connect-VIServer -Server "vms-vc-pro-1.mcs.usyd.edu.au"
#Connect-VIServer -Server "vcloud-vc-pro-1.shared.sydney.edu.au"
# Get the datacenter
$Datacenter = Get-Datacenter -Name $DatacenterName
# Get the virtual machine
$VM = Get-VM -Location $Datacenter -Name $VMName
# Get the virtual hard disk (VMDK)
Get-HardDisk -VM $VM -DiskType "Flat"|foreach { 
    # Get the datastore
    $Datastore = Get-Datastore -Id $_.ExtensionData.Backing.Datastore
    # Get the device ID for the Storage Center volume
    # Remove "naa." from the canonical name
    $DeviceId = $Datastore.ExtensionData.Info.Vmfs.Extent[0].DiskName.Substring(4)
    $vollist+=$DeviceId
}
# Get the physical RDM
Get-HardDisk -VM $VM -DiskType "RawPhysical"|foreach {
    # Get the device ID for the Storage Center volume
    # Remove "naa." from the canonical name
    $DeviceId = $_.ScsiCanonicalName.Substring(4)
    $vollist+=$DeviceId
}
Disconnect-VIServer -Server "vms-vc-pro-1.mcs.usyd.edu.au" -Confirm:$false
#Disconnect-VIServer -Server "vcloud-vc-pro-1.shared.sydney.edu.au" -Confirm:$false
#$conn = Connect-DellApiConnection -HostName mgmt-em-pro-1.shared.sydney.edu.au -User Admin
$vollist=$vollist|Select-Object -Unique
Get-DellStorageCenter -Connectionname $conn |Select-Object Name|foreach {
    $scname=$_.Name
    foreach ($DeviceId in $vollist ) {
        $ScVolume = Get-DellScVolume -Connectionname $conn -ScName $scname -DeviceId $DeviceId
        if ( $ScVolume )
        {
            # Display the Storage Center volume folder and volume name
            #$ScVolume | Select-Object ScName, VolumeFolderPath, Name
            $ScVolume | Select-Object Name
        }
    }
}