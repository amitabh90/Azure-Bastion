function New-PublicIpAddress {
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
        Position = 6,
        Mandatory = $true,
        HelpMessage = 'Provide the name of public ip address to be created'
    )]
    [string]$PublicIpAddressName,
    [Parameter(
        Position = 7,
        Mandatory = $true,
        HelpMessage = 'Provide the DomainNameLabel of public ip address to be created,its should be globally unique'
    )]
    [string]$PublicIpDomainNameLabel
)
    write-Output '*************************************************************************************************************************************************************'
    try {
        Write-Output ('Checking if a PublicIP already exists with the name : {0}' -f $PublicIpAddressName)

        $PublicIP = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $PublicIpAddressName -ErrorAction SilentlyContinue
        if (-not $PublicIP) {
             write-Output $ManageIdentityName 'STARTED: Creating the Public IP Address'
             write-Output '_______________________________________________________________________________________________________________________________________________________________'
            $PublicIpAddressParam = @{
                ResourceGroupName = $ResourceGroupName
                Name              = $PublicIpAddressName
                Location          = $Location
                AllocationMethod  = 'Static'
                Sku               = 'Standard'
                IpAddressVersion  = 'IPv4'
                DomainNameLabel   = $PublicIpDomainNameLabel
            }
            $PublicIP = New-AzPublicIpAddress @PublicIpAddressParam  -ErrorAction SilentlyContinue
            write-Output  $PublicIP
            write-Output '_______________________________________________________________________________________________________________________________________________________________'
            write-Output $ManageIdentityName 'COMPLETED: Creating the Public IP Address'
        }
        else {
            Write-Output ('A PublicIP already exists with the name : {0}' -f $PublicIpAddressName)
        }
    }
    catch {
       Write-Host $_.Exception.Message -ForegroundColor Red
        throw
    }
    write-Output '*************************************************************************************************************************************************************'
}