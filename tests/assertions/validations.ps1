param(
    [string]$resourcegroup_name = $(throw "-resourcegroup_name is required."),
    [string]$resourcegroup_name_expected_value = $(throw "-resourcegroup_name_expected_value is required."),
    [string]$resource_group_name_sensitive = $(throw "-resource_group_name_sensitive is required."),
    [string]$resource_group_name_sensitive_expected_value = $(throw "-resource_group_name_sensitive_expected_value is required.")
)

Write-Host "'$($resourcegroup_name)' should be equal to '$($resourcegroup_name_expected_value)'"

If ($resourcegroup_name -ne $resourcegroup_name_expected_value) {
    throw
}

Write-Host "'$($resource_group_name_sensitive)' should be equal to '$($resource_group_name_sensitive_expected_value)'"

If ($resource_group_name_sensitive -ne $resource_group_name_sensitive_expected_value) {
    throw
}
