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

    Write-Output "Output FileName: '$outputFileName'"

    # Get terraform execution path.
    $terraform = "terraform"
    if (-not ([string]::IsNullOrEmpty($input_pathToTerraform)))
    {
        $terraform = $input_pathToTerraform + "\terraform.exe"
    }

    Write-Output "Terraform path: '$terraform'"

    # Prepare the external command values.
    $cmdPath = $env:ComSpec
    Assert-VstsPath -LiteralPath $cmdPath -PathType Leaf
    # Command line switches:
    # /D     Disable execution of AutoRun commands from registry.
    # /E:ON  Enable command extensions. Note, command extensions are enabled
    #        by default, unless disabled via registry.
    # /V:OFF Disable delayed environment expansion. Note, delayed environment
    #        expansion is disabled by default, unless enabled via registry.
    # /S     Will cause first and last quote after /C to be stripped.
    #
    # Note, use CALL otherwise if a script ends with "goto :eof" the errorlevel
    # will not bubble as the exit code of cmd.exe.
    $arguments = "/D /E:ON /V:OFF /S /C `"CALL `"$terraform output -json > $outputFileName`"`""
    $splat = @{
        'FileName' = $cmdPath
        'Arguments' = $arguments
        'WorkingDirectory' = $input_workingDirectory
    }

    # Switch to "Continue".
    $global:ErrorActionPreference = 'Continue'
    $failed = $false

    # Run the script.
    if (!$input_failOnStderr) {
        Invoke-VstsTool @splat
    } else {
        $inError = $false
        $errorLines = New-Object System.Text.StringBuilder
        Invoke-VstsTool @splat 2>&1 |
            ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    # Buffer the error lines.
                    $failed = $true
                    $inError = $true
                    $null = $errorLines.AppendLine("$($_.Exception.Message)")

                    # Write to verbose to mitigate if the process hangs.
                    Write-Verbose "STDERR: $($_.Exception.Message)"
                } else {
                    # Flush the error buffer.
                    if ($inError) {
                        $inError = $false
                        $message = $errorLines.ToString().Trim()
                        $null = $errorLines.Clear()
                        if ($message) {
                            Write-VstsTaskError -Message $message
                        }
                    }

                    Write-Host "$_"
                }
            }

        # Flush the error buffer one last time.
        if ($inError) {
            $inError = $false
            $message = $errorLines.ToString().Trim()
            $null = $errorLines.Clear()
            if ($message) {
                Write-VstsTaskError -Message $message
            }
        }
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

    $outputvariable = (Get-Content $input_pathToTerraform\$outputFileName) | ConvertFrom-Json 

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

    # Fail if any errors.
    if ($failed) {
        Write-VstsSetResult -Result 'Failed' -Message "Error detected" -DoNotThrow
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}


