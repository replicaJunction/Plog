function Get-LogFileName {
    [CmdletBinding()]
    param(
        # Name of the script file calling Write-Log
        [Parameter(Mandatory = $false,
                   Position = 0)]
        [String] $ScriptName
    )
    
    begin {
        $p = Get-ModulePrivateData
        
        # Use a script-wide variable for performance
        if ($script:fileDateFormat -eq $null) {
            $script:fileDateFormat = 'yyyyMMdd-HHmm'
        }
    }
    
    process {
        if ($p.Mode -eq 'File') {
            if (-not ($script:currentLogFile)) {
                if (-not $ScriptName) {
                    # Get the filename of the main script file
                    $ScriptName = $MyInvocation.ScriptName | Split-Path -Leaf
                }
                else {
                    Write-Debug "Plog: Using provided ScriptName $ScriptName"
                }
                
                if ($ScriptName -like '*.ps1') {
                    # Remove the .ps1 from the script name
                    $ScriptName = $ScriptName.substring(0, $ScriptName.LastIndexOf('.'))
                }
                Write-Debug "Plog: History mode is $($p.History.Mode)"
                switch ($p.History.Mode) {
                    'StructuredFolder' {
                        # Place the log file in a folder named after the script file
                        $logFileName = '{0}\{0}_{1}.log' -f $ScriptName, (Get-Date -Format $script:fileDateFormat)
                    }
                    Default {
                        # Also includes 'Simple'. Place the log file in the path specified.
                        $logFileName = '{0}_{1}.log' -f $ScriptName, (Get-Date -Format $script:fileDateFormat)
                    }
                }
                
                $script:currentLogFile = Join-Path -Path $p.Path -ChildPath $logFileName
                Write-Debug "Plog: using new log filename $($script:currentLogFile)"  
                
                $logDir = Split-Path -Path $script:currentLogFile -Parent
                if (-not (Test-Path -Path $logDir)) {
                    Write-Debug "Plog: creating log directory $logDir"
                    [void] (New-Item -Path $logDir -ItemType 'Directory' -Force)
                }
            }
            else {
                Write-Debug "Plog: using existing log file $($script:currentLogFile)"
            }
            
            Write-Output $script:currentLogFile
        }
        else {
            Write-Debug "Not in File mode, so there is no filename for logging"
        }
    }
}
