Function New-VCluster

    {
      <#
        .SYNOPSIS
        Deploy a virtual cluster on Hyper-V

        .DESCRIPTION
        This script helps to deploy a defined number of Virtual Machines, with base image or blank os disk.
        You could add defined number of data disks with custom size. Custom amount of Nics attached to the same existing switch.
        Define number of CPU cores amount of Physical Memory.

        .PARAMETER Nodes
        Number of Cluster nodes.

        .PARAMETER NodeName
        Name of the VMs, numbers will be added to the end

        .PARAMETER Cores
        Number of CPU cores.

        .PARAMETER Memory
        Amount of Memory. Usage "4GB"

        .PARAMETER Datadisks
        Number of data disks.

        .PARAMETER Disksize
        Size of the disks. Usage "32GB"
        
        .PARAMETER NICS
        Amount of NICS.

        .PARAMETER SwitchName
        Hyper-V switch where the NICS will be attached.

        .PARAMETER BaseImage
        Path of BaseImage (vhdx) which will be copied as OS disk

        
        .PARAMETER ISOLocation
        Path to the ISO which will be mounted during VM creation.



        .EXAMPLE
        PS> New-VCluster -Nodes 2 -NodeName OSAZHCI -Cores 2 -Memory 4GB -Baseimage D:\Scripts\AzSHCI20H2_G2.vhdx -Nics 4 -Switchname Private -DataDisks 4 -DataDiskSize 32GB

    #>
        Param 
        (
         [Parameter(Mandatory=$true)]
            [int]$Nodes,
            [string]$NodeName,
            [int]$Cores,
            $Memory,
            [int]$DataDisks,
            $DataDiskSize,
            [string]$Nics,
            $Switchname,
        [Parameter(Mandatory=$false)]
            $Baseimage,
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
