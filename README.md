# Bicep Module Test Pattern

This is an example of how [Bicep](https://aka.ms/bicep) modules can be unit tested. The pattern is similar to unit testing of code. A test is written as Bicep files that consumes the module being tested. A simple test runner executes the Bicep test. The test runner can be included with the tests and designed to meet the needs of the development team.

## Module Design

Each module is an independently deployable, reusable, and testable unit of automation. Modules can have dependencies, e.g., testing a module that deploys a KeyVault secret requires a KeyVault to contain the secret, but dependencies are minimized in order to simplify testing of the individual modules.

## Tests

Each module has at least one corresponding unit test, in the form of a Bicep file. The test Bicep files perform any necessary setup and then invoke the module being tested. Test modules do not have any required parameters (but they may have parameters with defaults).

All tests are in the `tests` directory and have a naming convention of `*.tests.bicep`.

## Deployment Scope

The modules being tested do not require a specific scope and can be reused in any deployment scope: resource group, subscription, or tenant. The test Bicep files operate in the resource group scope.

## Test Runner

The example test runner is a PowerShell script that invokes the Azure CLI to create a new resource group deployment for the current test being executed. Test runners can be written in whatever language you prefer. This test runner takes a parameter for the test Bicep file and creates a new resource group deployment. Below is a summary of using the test runner. Get more detailed help by running the `Get-Help` command in a PowerShell window: `Get-Help -Name .\Test-Module.ps1 -Detailed`.

### Invoking a Test

To run a single unit test:

```PowerShell
.\Test-Module.ps1 -ModuleFile .\tests\<test name>.tests.bicep
```

For example:

```PowerShell
.\Test-Module.ps1 -ModuleFile .\tests\keyvault.tests.bicep
```

The test runner creates a new resource group if the resource group does not already exist. Then it runs the given Bicep test file in a new resource group deployment. Errors and results are displayed when the test finishes.

### Test Cleanup

The test runner will delete the test resource group and all deployments when run with the `-Cleanup` switch.

```PowerShell
.\Test-Module.ps1 -Cleanup -NoWait
```
