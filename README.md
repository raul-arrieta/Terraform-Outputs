# Terraform-Outputs

This extension enables you to use the Terraform outputs as variables in your Azure Pipelines.

## Terraform Outputs Task

[![task-screenshot](images/task.png "task-screenshot")](images/task.png)

This task will execute 'terraform output -json' command within the provided "Path to Terraform scripts" and map all these values to pipeline variables.

It is possible to indicate if you want to map the sensitive outputs as secrets (thanks to [@joseph-passineau](https://github.com/joseph-passineau) :blush:).

You can also provide a common prefix that will be applied to each of the variable names.

Optionally a path to Terraform assembly can be provided. If it's available in PATH this value can be leave empty.

## Build pipeline

[![Build status](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_apis/build/status/CI.Terraform-Outputs.Master)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_build/latest?definitionId=1)

CI build pipeline that packages the vsix extension and publishes two artifacts:
- terraform-outputs-extension: includes the packaged extension.
- terraform-test: contains .tf files and a powershell script used to validate the extension.


## Release pipeline

CD release pipeline is composed of three different stages:

### Development:

[![Development](https://vsrm.dev.azure.com/raul-arrieta/_apis/public/Release/badge/08ec166f-369d-440c-9dec-3b2a2d8888f9/1/1)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_release?view=mine&definitionId=1) 

Publishes a private version of the extension tagged as "development". 

Before running next stage there is a deployment gate to check that the extension has been successfully validated by the marketplace.

### Validation:

[![Validation](https://vsrm.dev.azure.com/raul-arrieta/_apis/public/Release/badge/08ec166f-369d-440c-9dec-3b2a2d8888f9/1/2)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_release?view=mine&definitionId=1) 

Executes the same task group on three different hosted agents:
- Windows Validation: Hosted VS2017 agent pool.
- Linux Validation: Hosted Ubuntu 1604 agent pool.
- MacOS Validation: Hosted macOS agent pool.

The task group:
- Installs the extension that has been published on Development stage.
- Installs Terraform and executes init and apply using 'terraform-test' published artifact.
- Run Terraform Outputs without prefix.
- Executes a powershell to check that the variable has been published and contains the appropriate value.
- Run Terraform Outputs with prefix.
- Executes a powershell to check that the variable has been published using the provided prefix and contains the appropriate value.

### Production

[![Production](https://vsrm.dev.azure.com/raul-arrieta/_apis/public/Release/badge/08ec166f-369d-440c-9dec-3b2a2d8888f9/1/3)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_release?view=mine&definitionId=1)

Once it has been approved this stage publishes the extension to the marketplace.