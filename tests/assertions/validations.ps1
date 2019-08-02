param(
    [string]$resourcegroup_name = $(throw "-resourcegroup_name is required."),
    [string]$resourcegroup_name_expected_value = $(throw "-resourcegroup_name_expected_value is required.")
    [string]$resource_group_name_sensitive = $(throw "-resource_group_name_sensitive is required."),
    [string]$resource_group_name_sensitive_expected_value = $(throw "-resource_group_name_sensitive_expected_value is required.")
)

If ($resourcegroup_name -ne $resourcegroup_name_expected_value) {
    throw
}

If ($resource_group_name_sensitive -ne $resource_group_name_sensitive_expected_value) {
    throw
}
