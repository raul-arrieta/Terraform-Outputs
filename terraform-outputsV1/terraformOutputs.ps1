[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    Import-VstsLocStrings "$PSScriptRoot\task.json"

    # Get inputs.
    $input_failOnStderr = Get-VstsInput -Name 'failOnStderr' -AsBool
    $input_pathToTerraform = Get-VstsInput -Name 'pathToTerraform'
    $input_workingDirectory = Get-VstsInput -Name 'workingDirectory' -Require
    Assert-VstsPath -LiteralPath $input_workingDirectory -PathType 'Container'

    # Get output file.
    $outputFileName = [guid]::NewGuid();
    $outputFilePath = $input_workingDirectory+"\"+$outputFileName+".out"

    Write-Output "Output file path: '$outputFilePath'"

    # Get terraform execution path.
    $terraform = "terraform"
    if (-not ([string]::IsNullOrEmpty($input_pathToTerraform)))
    {
        $terraform = $input_pathToTerraform + "\terraform.exe"
    }

    $arguments = "output -json"

    Write-Output "Terraform path: '$terraform'"
    Write-Output "Terraform scripts path: '$input_workingDirectory'"
    Write-Output "Arguments: '$arguments'"

    $splat = @{
        'FileName' = $terraform
        'Arguments' = $arguments
        'WorkingDirectory' = $input_workingDirectory
    }

    # Switch to "Continue".
    $global:ErrorActionPreference = 'Continue'
    $failed = $false

    # Run the script.
    Invoke-VstsTool @splat | Out-File $outputFilePath

    $outputvariable = (Get-Content $outputFilePath) | ConvertFrom-Json 

    $outputvariable.PSobject.Properties | ForEach-Object {
        $name = $($_.Name)
        $value = ""

        $_.Value.PSobject.Properties | ForEach-Object {
            If($_.Name -eq "value"){
                $value = $_.Value
            }
        }

        Write-Host "##vso[task.setvariable variable=$name;]$value";
        Write-Output "[$name;$value]"
        Write-Output "------------------------------------------------------------"
    }


     # Fail on $LASTEXITCODE
     if (!(Test-Path -LiteralPath 'variable:\LASTEXITCODE')) {
        $failed = $true
        Write-Verbose "Unable to determine exit code"
        Write-VstsTaskError -Message (Get-VstsLocString -Key 'PS_UnableToDetermineExitCode')
    } else {
        if ($LASTEXITCODE -ne 0) {
            $failed = $true
            Write-VstsTaskError -Message (Get-VstsLocString -Key 'PS_ExitCode' -ArgumentList $LASTEXITCODE)
        }
    }

    # Fail if any errors.
    if ($failed) {
        Write-VstsSetResult -Result 'Failed' -Message "Error detected" -DoNotThrow
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}


