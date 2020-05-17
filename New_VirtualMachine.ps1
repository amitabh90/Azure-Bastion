function New_VirtualMachine {
    [CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        Mandatory = $true,
        HelpMessage = 'Provide the resource group name in where the NSG is present'
    )]
    [string]$ResourceGroupName,
    [Parameter(
        Position = 1,
        Mandatory = $true,
        HelpMessage = 'Provide the location for resources to be created'
    )]
    [string]$Location,
     [Parameter(
        Position = 2,
        Mandatory = $true,
        HelpMessage = 'Provide the admin username for VM'
    )]
    [string]$VMLocalAdminUser,
    [Parameter(
        Position = 3,
        Mandatory = $true,
        HelpMessage = 'Provide the admin password for VM'
    )]
    [string]$VMLocalAdminSecurePassword,
    [Parameter(
        Position = 4,
        Mandatory = $true,
        HelpMessage = 'Provide the name for VM'
    )]
    [string]$VMName,
    [Parameter(
        Position = 5,
        Mandatory = $true,
        HelpMessage = 'Provide the VM Size'
    )]
    [string]$VMSize,
    [Parameter(
        Position = 6,
        Mandatory = $true,
        HelpMessage = 'Provide the virtual network name '
    )]
    [string]$VirtualNetworkName,
    [Parameter(
        Position = 7,
        Mandatory = $true,
        HelpMessage = 'Provide the prod subnet name '
    )]
    [string]$ProdSubnetName,
    [Parameter(
        Position = 8,
        Mandatory = $true,
        HelpMessage = 'Provide the NIC name '
    )]
    [string]$NICName
)

## Get the defined vnet
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$Prodsubnet = $VirtualNetwork.Subnets | Where-Object Name -eq $ProdSubnetName

#Create NIC  and config for VM
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Prodsubnet.Id
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2012-R2-Datacenter' -Version latest

New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose

}




