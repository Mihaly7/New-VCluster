Function New-VCluster
    {
        Param 
        (
            [int]$Nodes,
            [string]$NodeName,
            [int]$Cores,
            $Memory,
            [int]$DataDisks,
            $DataDiskSize,
            [string]$Nics,
            [string]$Baseimage,
            $Switchname,
            $ISOlocation
        )

Function Prepare-OSdisk
{
    Param 
        (
            [string]$imagelocation,
            [string]$osdiskname
        )
    $Destination = (Get-VMHost).VirtualHardDiskPath+"\"+$osdiskname+".vhdx"
    Write-Host "Copy base image"
    Copy-Item (Get-ChildItem -Path $imagelocation).fullname -Destination $Destination -Verbose
}


If ($nodes -ne $null)
{
$Vhdpath = (get-vmhost).VirtualHardDiskPath
For ($j =1; $j -le $nodes; $j++)
{
$vmname = $Nodename+$j
    For ($d = 1; $d -le $DataDisks; $d++)
    {
    
    $Vhdname = $vmname+"data"+$d+".vhdx"
    New-VHD -Path $vhdpath"\"$Vhdname -SizeBytes $datadisksize -Fixed -verbose
    
    }

    If ($Baseimage -ne $null)
        {
            Prepare-OSdisk -imagelocation (Get-ChildItem $Baseimage).FullName $vmname
            $OsDrive = (get-vmhost).VirtualHardDiskPath+"\"+$vmname+".vhdx" 
            
            New-VM -name $VMname -VHDPath $Osdrive -Generation 2 -MemoryStartupBytes $Memory
        }

    Else
        {
            $OsDrive = (get-vmhost).VirtualHardDiskPath+"\"+$vmname+".vhdx" 
            New-VM -name $VMname -Generation 2 -MemoryStartupBytes $Memory -NewVHDPath $OsDrive -NewVHDSizeBytes 64GB
        }
        
    
    Get-VM $VMname | Set-VM -ProcessorCount $Cores
    
    $Disks = Get-ChildItem -Path ((get-vmhost).VirtualHardDiskPath).ToString() -Filter $vmname"data*"
    foreach ($Disk in $Disks)
        {
        Add-VMHardDiskDrive -VMName $vmname -ControllerType SCSI -ControllerNumber 0 -Path $Disk.FullName -Verbose
        }
    For ($i = 1; $i -le $Nics; $i++)
        {
        Add-VMNetworkAdapter -VMName $vmname -SwitchName $Switchname -Verbose
        }
    If ($ISOlocation -ne $null)
    {
        Add-VMDvdDrive -VMName $Vmname -Path $ISOlocation -Verbose
        $DVD = Get-VMDvdDrive -VMName $VMname
        Set-VMFirmware -VMName $VMname -FirstBootDevice $DVD -verbose
    }
    
    
    Set-VMProcessor -VMName $VMname -ExposeVirtualizationExtensions $true -verbose
    }
    }
}
