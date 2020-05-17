function New-VirtualNetwork {
    [CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        Mandatory = $true,
        HelpMessage = 'Provide the resource group name in where the resources is to be created'
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
        HelpMessage = 'Provide the virtual network name is to be created'
    )]
    [string]$VirtualNetworkName,
    [Parameter(
        Position = 3,
        Mandatory = $true,
        HelpMessage = 'Provide the Azure Bastion subnet name is to be created i.e AzureBastionSubnet'
    )]
    [string]$AzureBastionSubnetName = 'AzureBastionSubnet',
     [Parameter(
        Position = 4,
        Mandatory = $true,
        HelpMessage = 'Provide the Prod subnet name is to be created i.e Prod-Subnet'
    )]
    [string]$ProdSubnetName,
    [Parameter(
        Position = 5,
        Mandatory = $true,
        HelpMessage = 'Provide the VnetAddressPrefix for virtual network is to be created'
    )]
    [string]$VnetAddressPrefix,
    [Parameter(
        Position = 6,
        Mandatory = $true,
        HelpMessage = 'Provide the subnet AddressPrefix for  AzureBastionSubnet is to be created'
    )]
    [string]$AzureBastionSubnetAddressPrefix,
    [Parameter(
        Position = 7,
        Mandatory = $true,
        HelpMessage = 'Provide the subnet AddressPrefix for  ProdSubnet is to be created'
    )]
    [string]$ProdSubnetAddressPrefix
)

    try {
        write-Output ('Checking if a Virtual Network exists with the name: {0}' -f $VirtualNetworkName)

        $VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
        if (-not $VirtualNetwork) {
            write-Output 'STARTED: Creating the Virtual Network'
            write-Output '_______________________________________________________________________________________________________________________________________________________________'

            $AzureBastionSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $AzureBastionSubnetName -AddressPrefix $AzureBastionSubnetAddressPrefix
            $ProdSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $ProdSubnetName -AddressPrefix $ProdSubnetAddressPrefix
            $VirtualNetworkParam = @{
                ResourceGroupName = $ResourceGroupName
                Name              = $VirtualNetworkName
                Location          = $Location
                AddressPrefix     = $VnetAddressPrefix
                Subnet            = $AzureBastionSubnetConfig,$ProdSubnetConfig
            }
            $VirtualNetwork = New-AzvirtualNetwork @VirtualNetworkParam
            write-Output  $VirtualNetwork
            write-Output '_______________________________________________________________________________________________________________________________________________________________'
            write-Output  'COMPLETED: Creating the Virtual Network'
        }
        else {
            Write-Output ('A virtual network already exists with the name : {0}' -f $VirtualNetworkName)
            write-Output ('Checking if a Subnets within the Virtual Network exists with the name : {0}' -f $AzureBastionSubnetName,$ProdSubnetName)
            $AzureBastionsubnet = Get-AzVirtualNetworkSubnetConfig -Name $AzureBastionSubnetName -VirtualNetwork $VirtualNetwork -ErrorAction SilentlyContinue
            $Prodsubnet = Get-AzVirtualNetworkSubnetConfig -Name $ProdSubnetName -VirtualNetwork $VirtualNetwork -ErrorAction SilentlyContinue
            if (-not $AzureBastionsubnet) {
                write-Output 'STARTED: Creating the AzureBastionsubnet in the virtual network'
                write-Output '----------------------------------------------------------------------------------------------------------------------------------------------------------------'
                $AzureBastionsubnet = Add-AzVirtualNetworkSubnetConfig -Name $AzureBastionSubnetName -VirtualNetwork $VirtualNetwork -AddressPrefix $AzureBastionSubnetAddressPrefix
                $virtualNetwork | Set-AzVirtualNetwork
                write-Output  $AzureBastionsubnet
                write-Output '----------------------------------------------------------------------------------------------------------------------------------------------------------------'
                write-Output  'COMPLETED: Creating the AzureBastionsubnet in the virtual network'
            }
            if (-not $Prodsubnet) {
                write-Output 'STARTED: Creating the Prodsubnet in the virtual network'
                write-Output '----------------------------------------------------------------------------------------------------------------------------------------------------------------'
                $Prodsubnet = Add-AzVirtualNetworkSubnetConfig -Name $ProdSubnetName -VirtualNetwork $VirtualNetwork -AddressPrefix $ProdSubnetAddressPrefix
                $virtualNetwork | Set-AzVirtualNetwork
                write-Output  $Prodsubnet
                write-Output '----------------------------------------------------------------------------------------------------------------------------------------------------------------'
                write-Output  'COMPLETED: Creating the ProdSubnet in the virtual network'
            }
            else {
                Write-Output ('A SubNet within the virtual network already exists with the name : {0}' -f $AzureBastionSubnetName,$ProdSubnetName)
            }
        }
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        throw
    }
    write-Output '*************************************************************************************************************************************************************'
}