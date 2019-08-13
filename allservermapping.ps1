import-module "D:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
Import-Module "D:\Dell Storage Powershell\DellStorage.ApiCommandSet.psd1"
# Assign variables
$conn="DSMDC" 
$DC="PRD"
if ($DC -eq "PRD" )
{
    $vclist=@("vms-vc-pro-1.mcs.usyd.edu.au","vcloud-vc-pro-1.shared.sydney.edu.au","mgmt-vc-pro-1.shared.sydney.edu.au")
    $cml="blk.*prd"
}else
{
    $vclist=@("vms-vc-dr-1.mcs.usyd.edu.au","vcloud-vc-dr-1.shared.sydney.edu.au","mgmt-vc-dr-1.shared.sydney.edu.au")
    $cml="blk.*dr"
}
$filename='C:\Users\samxiang_admin\vmlunmapping.csv'
$outputfile='C:\Users\samxiang_admin\vmlunmapping1.csv'
$resultfile='C:\Users\samxiang_admin\allservermapping.csv'
$credentials=Get-Credential
echo "VM|App|uuid|size">$filename
foreach ( $vc in $vclist ) {
    Connect-VIServer -Server $vc -Credential $credentials
    $vmapp=@{}
    if ( $vc -eq "vcloud-vc-pro-1.shared.sydney.edu.au" )
    {
        Get-Tag -Category "Prefix"|Select-Object Name,Description|ForEach-Object {
            $vmapp.Add($_.Name,$_.Description)
        }
    }
    foreach ( $VM in  Get-VM -Server $vc ) {
        $volist=@()
        if ( $vmapp.ContainsKey([string]$VM.Folder))
        {
            $app=$vmapp[[string]$VM.Folder]
        }else
        {
            $app=[string]$VM.Folder
        }
        # Get the virtual hard disk (VMDK)
        Get-HardDisk -VM $VM |foreach { 
            # Get the datastore
            if ($_.DiskType -eq "Flat")
            {
                $Datastore = Get-Datastore -Id $_.ExtensionData.Backing.Datastore
                # Get the device ID for the Storage Center volume
                # Remove "naa." from the canonical name
                $volist+=$Datastore.ExtensionData.Info.Vmfs.Extent[0].DiskName.Substring(4)
            }else
            {
                # Get the physical RDM
                # Get the device ID for the Storage Center volume
                # Remove "naa." from the canonical name
                $volist+=$_.ScsiCanonicalName.Substring(4)
            }
            $volist|Select-Object -Unique|ForEach-Object {
                $VM.Name,$app,$_,[int32]$VM.ProvisionedSpaceGB -join '|'|Out-File -FilePath $filename -Append
            }
        }
    }
    Disconnect-VIServer -Server $vc -Confirm:$false
}
$vmtable=import-csv $filename -Delimiter '|'|sort uuid
echo "VM|Application|CML|profile|Cluster|GBsize|Replicated">$outputfile
Get-DellStorageCenter -Connectionname $conn |where-object { $_.Name -match $cml }|Select-Object Name|foreach {
    $scname=$_.Name
    $olduuid=''
    $newvmtable=@()
    $volfind=$false
    foreach ($vm in $vmtable ) {
        if ( $vm.uuid -eq $olduuid )
        {
            if ( $volfind )
            {
                $vm.VM,$vm.App,$scname,$profile,$ScVolume.VolumeFolderPath.split('/')[0],$vm.size,$ScVolume.ReplicationSource -join '|'|Out-File -FilePath $outputfile -Append
            }else
            {
                $newvmtable+=$vm
            }
        }else
        {
            $ScVolume = Get-DellScVolume -Connectionname $conn -ScName $scname -DeviceId $vm.uuid
            if ( $ScVolume )
            {
                # Display the Storage Center volume folder and volume name
                $volfind=$true
                $volconfig=Get-DellScVolumeConfiguration -ConnectionName $conn -Instance $ScVolume.InstanceId
                if( $volconfig.StorageProfile.InstanceName -match "Flash" )
                {
                    $profile="Gold"
                }else
                {
                    $profile=$volconfig.StorageProfile.InstanceName
                }
                $vm.VM,$vm.App,$scname,$profile,$ScVolume.VolumeFolderPath.split('/')[0],$vm.size,$ScVolume.ReplicationSource -join '|'|Out-File -FilePath $outputfile -Append
             }else
            {
                $newvmtable+=$vm
                $volfind=$false
            }
            $olduuid=$vm.uuid
        }
    }
    $vmtable=$newvmtable
    Get-DellScServer -ConnectionName $conn -ScName $scname -Connectivity Up |Where-Object { $_.Operatingsystem -notmatch "Compellent" -and $_.Operatingsystem -notmatch "VMware"} `
        |foreach {
        $MappingList =Get-DellScMappingProfile -ConnectionName $conn -Server $_
        $cap=Get-DellScServerStorageUsage -Instance $_.InstanceId -ConnectionName $conn
        $os=$_.Operatingsystem.InstanceName
        ForEach( $Mapping in $MappingList )
        {
            $ScVolume=Get-DellScVolume -ConnectionName $conn -Instance $Mapping.Volume
            $volconfig=Get-DellScVolumeConfiguration -ConnectionName $conn -Instance $ScVolume.InstanceId
            if( $volconfig.StorageProfile.InstanceName -match "Flash" )
            {
                $profile="Gold"
            }else
            {
                $profile=$volconfig.StorageProfile.InstanceName
            }
            $cap.InstanceName,"Physical",$scname,$profile,$os,[int32]($cap.ConfiguredSpace.ByteSize/1gb),$ScVolume.ReplicationSource -join '|'|Out-File -FilePath $outputfile -Append
        }
   }
}
Import-Csv -Delimiter '|' $outputfile |sort -Unique VM,CML,profile,Replicated|export-csv -Delimiter '|' $resultfile -NoTypeInformation
