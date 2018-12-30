# Terraform-Outputs

This extension enables you to use the Terraform outputs as variables in your Azure Pipelines.

## Terraform Outputs Task

[![task-screenshot](images/task.png "task-screenshot")](images/task.png)

This task will execute 'terraform output -json' command within the provided "Path to Terraform scripts" and map all these values to pipeline variables.

Optionally a path to Terraform assembly can be provided. If it's available in PATH this value can be leave empty.


## CI Build pipeline
[![Build status](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_apis/build/status/CI.Terraform-Outputs.Master)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_build/latest?definitionId=1)

## CD Release pipeline
[![Development](https://vsrm.dev.azure.com/raul-arrieta/_apis/public/Release/badge/08ec166f-369d-440c-9dec-3b2a2d8888f9/1/1)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_release?view=mine&definitionId=1) [![Validation](https://vsrm.dev.azure.com/raul-arrieta/_apis/public/Release/badge/08ec166f-369d-440c-9dec-3b2a2d8888f9/1/2)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_release?view=mine&definitionId=1) [![Production](https://vsrm.dev.azure.com/raul-arrieta/_apis/public/Release/badge/08ec166f-369d-440c-9dec-3b2a2d8888f9/1/3)](https://dev.azure.com/raul-arrieta/Terraform%20Outputs/_release?view=mine&definitionId=1)
