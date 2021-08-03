[CmdletBinding()]
param (
    
    # Relative or absolute path of a module file containing one or more tests
    [Alias("m", "f")]
    [Parameter(Mandatory=$true)]
    [ValidateScript({[System.IO.File]::Exists($_)}, ErrorMessage="ModuleFile not found.")]
    [string]
    $ModuleFile,

    # The name of the resource group that will contain the test deployment. The group will be created if it does not exist.
    [Alias("g", "r")]
    [Parameter()]
    [string]
    $ResourceGroupName = "bicep-tests",

    # The location of the resource group and deployments
    [Alias("l")]
    [Parameter()]
    [string]
    $Location = 'eastus',

    # ARM Deployment mode. "Complete" or "Incremental"
    [Parameter()]
    [ValidateSet("Complete", "Incremental")]
    [string]
    $Mode = "Incremental",

    # Name of the deployment
    [Alias("n")]
    [Parameter()]
    [string]
    $DeploymentName = "bicep-test-$($(Get-Date).Ticks)",

    # Deletes the test resource group specified in the -ResourceGroupName parameter. Other parameters are ignored.
    [Alias("c")]
    [switch]
    $Cleanup
)

$ErrorActionPreference = "Stop"

if($Cleanup)
{
    Write-Host "[INFO]: Resource group '$ResourceGroupName' marked for deletion."
    $null = $(az group delete -y --no-wait --name $ResourceGroupName)
    exit;
}

# Create the test resource group if it does not exist
if($(az group exists -n $ResourceGroupName) -eq 'false')
{
    Write-Output "[INFO]: Creating resource group $ResourceGroupName in location $Location."
    $null = $(az group create --location $location --name $ResourceGroupName)
    if($LASTEXITCODE -ne 0) { exit; }
}
else 
{
    Write-Output "[INFO]: Using resource group $ResourceGroupName in location $Location."
}

Write-Host "[INFO]: Using deployment name $DeploymentName"
Write-Host "[INFO]: Running tests in $ModuleFile"
az deployment group create --template-file $moduleFile --resource-group $resourceGroupName --mode $Mode --name $DeploymentName --no-prompt --verbose
