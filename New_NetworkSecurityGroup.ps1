#Create NSG for subnet and associate with subnet
function New-NetworkSecurityGroup {
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
        HelpMessage = 'Provide the AzureBastionSubnet NSG name'
    )]
    [string]$AzureBastionSubnetNSG,
    [Parameter(
        Position = 3,
        Mandatory = $true,
        HelpMessage = 'Provide the virtual network name '
    )]
    [string]$VirtualNetworkName,
    [Parameter(
        Position = 4,
        Mandatory = $true,
        HelpMessage = 'Provide the Azure Bastion subnet name '
    )]
    [string]$AzureBastionSubnetName = 'AzureBastionSubnet',
     [Parameter(
        Position = 5,
        Mandatory = $true,
        HelpMessage = 'Provide the Prod subnet name '
    )]
    [string]$ProdSubnetName,
   [Parameter(
        Position = 6,
        Mandatory = $true,
        HelpMessage = 'Provide the subnet AddressPrefix for  AzureBastionSubnet '
    )]
    [string]$AzureBastionSubnetAddressPrefix,
    [Parameter(
        Position = 7,
        Mandatory = $true,
        HelpMessage = 'Provide the subnet AddressPrefix for  ProdSubnet '
    )]
    [string]$ProdSubnetAddressPrefix,
    [Parameter(
        Position = 8,
        Mandatory = $true,
        HelpMessage = 'Provide the prod NSG name'
    )]
    [string]$ProdSubnetNameNSG
)
try {
        #Creating NSG rules
        $AzureBastion_rule = New-AzNetworkSecurityRuleConfig -Name "Allow_TSL_SSL" -Description "Allow TSL and SSL ports" -Access `
            Allow -Protocol * -Direction Inbound -Priority 200 -SourceAddressPrefix $ProdSubnetAddressPrefix `
            -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443
        $RDP_SSH_rule = New-AzNetworkSecurityRuleConfig -Name "Allow_RDP_SSH" -Description "Allow RDP and SSH ports" -Access `
            Allow -Protocol * -Direction Inbound -Priority 201 -SourceAddressPrefix $AzureBastionSubnetAddressPrefix `
            -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22,3389
        ##Create the NSG
        $AzureBastion_NSG = New-AzNetworkSecurityGroup `
            -Name "$AzureBastionSubnetNSG" `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -SecurityRules $AzureBastion_rule;
        $Prod_NSG = New-AzNetworkSecurityGroup `
            -Name "$ProdSubnetNameNSG" `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -SecurityRules $RDP_SSH_rule;
        ## Get the defined vnet
        $VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

        ## Get the subnet from the Vnet
        $AzureBastionsubnet = $VirtualNetwork.Subnets | Where-Object Name -eq $AzureBastionSubnetName
        $Prodsubnet = $VirtualNetwork.Subnets | Where-Object Name -eq $ProdSubnetName

        # Associate NSG to selected Subnet
        Set-AzVirtualNetworkSubnetConfig  `
            -VirtualNetwork $VirtualNetwork `
            -Name $AzureBastionSubnetName `
            -AddressPrefix $AzureBastionsubnet.AddressPrefix `
            -NetworkSecurityGroup $AzureBastion_NSG | Set-AzVirtualNetwork;
        Set-AzVirtualNetworkSubnetConfig  `
            -VirtualNetwork $VirtualNetwork `
            -Name $ProdSubnetName `
            -AddressPrefix $Prodsubnet.AddressPrefix `
            -NetworkSecurityGroup $Prod_NSG | Set-AzVirtualNetwork;
}
catch {
    Write-Host $_.Exception.Message
}
}