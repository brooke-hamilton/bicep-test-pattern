[CmdletBinding()]
param (
    
    # Relative or absolute path of a module file containing one or more tests
    [Alias("m", "f")]
    [Parameter()]
    [ValidateScript( { Get-Item -Path $_ }, ErrorMessage = "ModuleFile not found.")]
    [string]
    $ModuleFile,

    # The name of the resource group that will contain the test deployment. The group will be created if it does not exist. The default is 'bicep-tests'.
    [Alias("g", "r")]
    [Parameter()]
    [string]
    $ResourceGroupName = "bicep-tests",

    # The location of the resource group and deployments. The default is 'eastus'.
    [Alias("l")]
    [Parameter()]
    [string]
    $Location = 'eastus',

    # ARM Deployment mode. "Complete" or "Incremental". The default is "Incremental".
    [Parameter()]
    [ValidateSet("Complete", "Incremental")]
    [string]
    $Mode = "Incremental",

    # Name of the deployment. The default is "bicep-test-<current ticks>".
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

function Log ([string]$message) {
    Write-Host "[INFO]: $message"
}

function GroupExists {
    return [bool]::Parse($(az group exists -n $ResourceGroupName))
}

function Clean {
    if ($(GroupExists)) {
        Log "Resource group '$ResourceGroupName' marked for deletion."
        $null = $(az group delete -y --no-wait --name $ResourceGroupName)
    }
    else {
        Log "Test resource group $ResourceGroupName does not exist. Nothing to clean."
    }
}

function CreateTestResourceGroup {
    if (!$(GroupExists)) {
        Log "Creating resource group $ResourceGroupName in location $Location."
        $null = $(az group create --location $location --name $ResourceGroupName)
        if ($LASTEXITCODE -ne 0) { exit; }
    }
    else {
        Log "Using resource group $ResourceGroupName in location $Location."
    }
}

function Deploy ([bool]$async, [string]$testFile, [string]$currentDeploymentName) {
    Log "Using deployment name $currentDeploymentName"
    Log "Running tests in $testFile"
    
    $command = "az deployment group create --template-file $testFile --resource-group $resourceGroupName --mode $Mode --name $currentDeploymentName --no-prompt --verbose"
    Invoke-Expression -Command $command
}

function FindTestFiles {
    if ($ModuleFile) {
        return Get-Item -Path $ModuleFile
    }
    else {
        return Get-ChildItem -Path *.tests.bicep -Recurse
    }
}

if ($Cleanup) {
    Clean
    exit
}

CreateTestResourceGroup

$testFiles = FindTestFiles
if (!$testFiles) {
    Log "No test modules found."
    exit
}

$useAsync = $testFiles.Count -gt 1 # Run tests asynchronously if there are more than one.
$deploymentCount = 1
foreach ($testFile in $testFiles) {
    Deploy -async $useAsync -testFile $testFile -currentDeploymentName "$DeploymentName-$deploymentCount"
    $deploymentCount++
}
