param (
        $Resourcegroupname = '',
        $Tag = " "
)

Write-Information "DUPSUG is $Tag"
$Present = Get-AzResourceGroup $Resourcegroupname -ErrorAction stop

if ($Present.tags.DUPSUG) {
    Write-Information "Tag present"
    
    if ($Present.tags.CostCenter -ne $Tag) {
        Write-Information "Tag not eq"
        $tags = @{"DUPSUG" = $Tag; }
        $resourceGroup = Get-AzResourceGroup -Name $Resourcegroupname
        Update-AzTag -ResourceId $resourceGroup.ResourceId -Tag $tags -Operation Merge
    }
}
Else {
    $tags = @{"DUPSUG" = $Tag }
    $resourceGroup = Get-AzResourceGroup -Name  $Resourcegroupname
    New-AzTag -ResourceId $resourceGroup.ResourceId -tag $tags
}