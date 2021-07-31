[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $moduleFile,

    [Parameter()]
    [string]
    $resourceGroupName
)


az deployment group create -f $moduleFile -g $resourceGroupName