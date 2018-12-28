param(
    [string]$resourcegroupname = $(throw "-resourcegroupname is required."),
    [string]$expectedvalue = $(throw "-expectedvalue is required.")
)

If ($resourcegroupname -ne $expectedvalue) {
    throw
}