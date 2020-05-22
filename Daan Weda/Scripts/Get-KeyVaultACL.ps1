param(
    [string][parameter(Mandatory = $true)] 
    $Resourcegroupname
)


write-information "Working in RG $Resourcegroupname" -InformationAction Continue
$RG = Get-AzResourceGroup -Name $Resourcegroupname
if(-not$RG){exit;}
$ResourceType = "Microsoft.KeyVault/vaults"
$Resource = Get-AzResource -ResourceGroupName $Resourcegroupname -ResourceType $ResourceType
if (-not$Resource) { exit; }
$keyVaultAccessPolicies = (Get-AzKeyVault -ResourceGroupName $resourcegroupname -VaultName $Resource.name).accessPolicies


$armAccessPolicies = @()

if ($keyVaultAccessPolicies) {
    foreach ($keyVaultAccessPolicy in $keyVaultAccessPolicies) {
        $armAccessPolicy = [pscustomobject]@{
            tenantId = $keyVaultAccessPolicy.TenantId
            objectId = $keyVaultAccessPolicy.ObjectId
        }

        $armAccessPolicyPermissions = [pscustomobject]@{
            keys         = $keyVaultAccessPolicy.PermissionsToKeys
            secrets      = $keyVaultAccessPolicy.PermissionsToSecrets
            certificates = $keyVaultAccessPolicy.PermissionsToCertificates
            storage      = $keyVaultAccessPolicy.PermissionsToStorage
        }

        $armAccessPolicy | Add-Member -MemberType NoteProperty -Name permissions -Value $armAccessPolicyPermissions

        $armAccessPolicies += $armAccessPolicy
    }
}

$armAccessPoliciesParameter = [pscustomobject]@{
    list = $armAccessPolicies
}

$armAccessPoliciesParameter = $armAccessPoliciesParameter | ConvertTo-Json -Depth 5 -Compress

Write-Host ("##vso[task.setvariable variable=KeyVault.AccessPolicies;]$armAccessPoliciesParameter")
Write-Host "##vso[task.setvariable variable=SetACL;]true"