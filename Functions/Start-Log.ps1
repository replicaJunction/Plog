function Start-Log {
    [CmdletBinding()]
    param (
        [ValidateScript({ Split-Path $_ -Parent | Test-Path })]
        [String] $FilePath,

        [Switch] $Clear
    )
    
    begin {
        $p = Get-ModulePrivateData       
    }

    process {
        try {
            if ($Clear -and (Test-Path -Path $FilePath)) {
                # Delete the log file. This will cause it to be re-created below.
                [void] (Remove-Item -Path $FilePath -Force )
            }
            
            if (-not (Test-Path -Path $FilePath)) {
	            # Create the log file
	            [void] (New-Item $FilePath -Type File)
            }
            $p.FilePath = $FilePath
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }

    end {
        # Save changes to module PrivateData
        Set-ModulePrivateData -PrivateData $p
    }
}