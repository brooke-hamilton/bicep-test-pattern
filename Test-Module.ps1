<#
.SYNOPSIS
This is an example of a Bicep module test runner.

.DESCRIPTION
The example test runner is a PowerShell script that invokes the Azure CLI to
create a new resource group deployment for the current test being executed.
Test runners can be written in whatever language you prefer. This test runner
takes a parameter for the test Bicep file and creates a new resource group
deployment.

.EXAMPLE
PS> .\Test-Module -ModuleFile .\tests\keyvault.tests.bicep

.EXAMPLE
PS> .\Test-Module -Cleanup

#>


[CmdletBinding()]
param (

    [Alias("m", "f")]
    [Parameter(ParameterSetName = 'RunTests', Position = 0)]
    [ValidateScript( { Get-Item -Path $_ }, ErrorMessage = "ModuleFile not found.")]
    [string]
    # Relative or absolute path of a module file containing one or more tests
    $ModuleFile,

    [Alias("c")]
    [Parameter(ParameterSetName = 'Cleanup', Mandatory = $true)]
    [switch]
    # Deletes the test resource group specified in the -ResourceGroupName parameter.
    # Other parameters are ignored.
    $Cleanup,

    [Alias("g", "r")]
    [Parameter(ParameterSetName = 'RunTests')]
    [Parameter(ParameterSetName = 'Cleanup')]
    [string]
    # The name of the resource group that will contain the test deployment. The
    # group will be created if it does not exist. The default is 'bicep-tests'.
    $ResourceGroupName = "bicep-tests",

    [Alias("l")]
    [Parameter(ParameterSetName = 'RunTests')]
    [string]
    # The location of the resource group and deployments. The default is 'eastus'.
    $Location = 'eastus',

    [Parameter(ParameterSetName = 'RunTests')]
    [ValidateSet("Complete", "Incremental")]
    [string]
    # ARM Deployment mode. "Complete" or "Incremental". The default is
    # "Incremental".
    $Mode = "Incremental",

    [Alias("n")]
    [Parameter(ParameterSetName = 'RunTests')]
    [string]
    # Name of the deployment. The default is "bicep-test-<current ticks>".
    $DeploymentName = "bicep-test-$($(Get-Date).Ticks)",

    [Parameter(ParameterSetName = 'RunTests')]
    [Parameter(ParameterSetName = 'Cleanup')]
    [switch]
    # Runs the deployment asynchronously.
    $NoWait
)

$ErrorActionPreference = "Stop"

function Log ([string]$message) {
    Write-Output "[INFO]: $message"
}

function GroupExists {
    return [bool]::Parse($(az group exists -n $ResourceGroupName))
}

function Clean {
    if ($(GroupExists)) {

        if ($NoWait) {
            Log "Resource group '$ResourceGroupName' marked for deletion"
        }
        else {
            Log "Deleting resource group '$ResourceGroupName'"
        }

        $azArgs = "group", "delete", "--yes", "--name", $ResourceGroupName
        if ($NoWait) {
            $azArgs += "--no-wait"
        }

        az $azArgs
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
    if ($async) {
        Log "Running tests asynchronously in $testFile"
    }
    else {
        Log "Running tests and waiting for results in $testFile"
    }

    $azArgs = "deployment", "group", "create", "--verbose", "--template-file", $testFile, "--resource-group", $resourceGroupName, "--mode", $Mode, "--name", $currentDeploymentName
    if ($async) {
        $azArgs += '--no-wait'
    }

    az @azArgs
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

$useAsync = $NoWait -or ($testFiles.Count -gt 1) # Run tests asynchronously if there are more than one.
$deploymentCount = 1
foreach ($testFile in $testFiles) {
    Deploy -async $useAsync -testFile $testFile -currentDeploymentName "$DeploymentName-$deploymentCount"
    $deploymentCount++
}
