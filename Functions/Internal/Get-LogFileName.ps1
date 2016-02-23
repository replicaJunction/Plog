function Get-LogFileName {
    [CmdletBinding()]
    param(
        # Name of the script file calling Write-Log
        [Parameter(Mandatory = $false,
                   Position = 0)]
        [String] $ScriptName,
        
        # Do not use the cached log filename 
        [Switch] $Force
    )
    
    begin {
        $p = Get-ModulePrivateData
        
        # Use a script-wide variable for performance
        if ($script:fileDateFormat -eq $null) {
            $script:fileDateFormat = 'yyyyMMdd-HHmm'
        }
    }
    
    process {
        if ($script:logFileName -and -not $Force) {
            Write-Debug "Get-LogFileName: Using cached log file [$($script:logFileName)]"
        }
        else {
            Write-Debug "Get-LogFileName: Building new log file name"
            if ($p.Mode -eq 'File') {
                if (-not $ScriptName) {
                    # Get the filename of the main script file
                    $ScriptName = $MyInvocation.ScriptName | Split-Path -Leaf
                }
                Write-Debug "Get-LogFileName: ScriptName is [$ScriptName]"
                if ($ScriptName -like '*.ps1') {
                    # Remove the .ps1 from the script name
                    $ScriptName = $ScriptName.substring(0, $ScriptName.LastIndexOf('.'))
                }
                Write-Debug "Get-LogFileName: Adjusted ScriptName is [$ScriptName]"

                switch ($p.History.Mode) {
                    'StructuredFolder' {
                        # Place the log file in a folder named after the script file
                        $logFileName = '{0}\{0}_{1}.log' -f $ScriptName, (Get-Date -Format $script:fileDateFormat)
                    }
                    'Simple' {
                        # Also includes 'Simple'. Place the log file in the path specified.
                        $logFileName = '{0}_{1}.log' -f $ScriptName, (Get-Date -Format $script:fileDateFormat)
                    }
                    default {
                        # This should never be hit
                        throw "Unsupported History mode [$($p.History.Mode)]"
                    }
                }
                $result = Join-Path -Path $p.Path -ChildPath $logFileName  
                Write-Debug "Get-LogFileName: returning value [$result]"
                
                $logDir = Split-Path -Path $result -Parent
                if (-not (Test-Path -Path $logDir)) {
                    Write-Debug "Plog: creating log directory $logDir"
                    [void] (New-Item -Path $logDir -ItemType 'Directory' -Force)
                }
                
                $script:logFileName = $result
            }
            else {
                Write-Debug "Not in File mode, so there is no filename for logging"
            }
        }
        
        Write-Output $script:logFileName
    }
}
