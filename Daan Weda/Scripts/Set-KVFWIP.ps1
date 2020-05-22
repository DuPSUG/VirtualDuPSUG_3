param (
        $Resourcegroupname  = '',
        $ClientIP           = ''
        
)

$ResourceType = "Microsoft.KeyVault/vaults"
$Resource = Get-AzResource -ResourceGroupName $Resourcegroupname -ResourceType $ResourceType
$KVCheck = Get-AzKeyVault -ResourceGroupName $Resourcegroupname -VaultName $Resource.name

if ($KVCheck.NetworkAcls.IpAddressRanges -notcontains ($ClientIP + "/32")) {
    Write-information -MessageData "Set Client IP Rule on KV" -InformationAction Continue
    Add-AzKeyVaultNetworkRule -VaultName $Resource.name -IpAddressRange $ClientIP
}
Update-AzKeyVaultNetworkRuleSet -VaultName $Resource.name -DefaultAction deny -Bypass AzureServices 

