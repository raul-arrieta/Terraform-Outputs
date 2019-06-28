param(
    [string]$resourcegroupname = $(throw "-resourcegroupname is required."),
    [string]$resourcegroupnameexpectedvalue = $(throw "-resourcegroupname is required.")
    [string]$containerregistryadminusername = $(throw "-containerregistryadminusername is required."),
    [string]$containerregistryadminusernameexpectedvalue = $(throw "-containerregistryadminusernameexpectedvalue is required.")
    [string]$containerregistryadminpassword = $(throw "-containerregistryadminpassword is required."),
    [string]$containerregistryadminpasswordexpectedvalue = $(throw "-containerregistryadminpasswordexpectedvalue is required.")
)

If ($resourcegroupname -ne $resourcegroupnameexpectedvalue) {
    throw
}

If ($containerregistryadminusername -ne $containerregistryadminusernameexpectedvalue) {
    throw
}

If ($containerregistryadminpassword -ne $containerregistryadminpasswordexpectedvalue) {
    throw
}