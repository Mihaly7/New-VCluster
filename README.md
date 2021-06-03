# New-VCluster
Quick and Dirty Virtual Cluster creation on Hyper-V

        .SYNOPSIS
        Deploy a virtual cluster on Hyper-V

        .DESCRIPTION
        This script helps to deploy a defined number of Virtual Machines, with base image or blank os disk.
        You could add defined number of data disks with custom size. Custom amount of Nics attached to the same existing switch.
        Define number of CPU cores amount of Physical Memory.

       .EXAMPLE
        PS> New-VCluster -Nodes 2 -NodeName TestCluster -Cores 2 -Memory 4GB -Baseimage D:\Scripts\AzSHCI20H2_G2.vhdx -Nics 4 -Switchname Private -DataDisks 4 -DataDiskSize 32GB
