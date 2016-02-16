function Set-LogMode {
    [CmdletBinding(DefaultParameterSetName = 'LogToFile')]
    param(
        # Path to the log file to use
        [Parameter(ParameterSetName = 'LogToFile',
                   Mandatory = $true)]
        [String] $FilePath,
        
        # Indicates that logging should be done to the Windows event log.
        [Parameter(ParameterSetName = 'LogToEventLog',
                   Mandatory = $true)]
        [Switch] $EventLog,
        
        # Name of the log to use. If not using the default, try Application.
        [Parameter(ParameterSetName = 'LogToEventLog',
                   Mandatory = $false)]
        [String] $LogName = 'Windows PowerShell',
        
        # Event source to use. Note that this event source must already exist!
        [Parameter(ParameterSetName = 'LogToEventLog',
                   Mandatory = $false)]
        [String] $Source = 'PowerShell',
        
        # Do not create a test event log entry. This is potentially dangerous
        # if you are using non-default log names or sources.
        [Parameter(ParameterSetName = 'LogToEventLog',
                   Mandatory = $false)]
        [Switch] $NoTest
    )
    
    begin {
        
        $p = Get-ModulePrivateData
        
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'LogToEventLog' {
                if (-not $NoTest) {
                    Write-Verbose "Creating a test event log entry to log $LogName with source $Source"
                    try {
                        Write-EventLog -LogName $LogName -Source $Source -EventID 12345 -EntryType Information -Message 'Plog is testing logging to the Windows Event Log. If this event is logged successfully, there are no problems.'
                    }
                    catch [System.Exception] {
                        $err = $_
                        throw "Plog was unable to log to the Windows Event Log: $err"
                    }
                }
                else {
                    Write-Verbose "-NoTest was specified. No test log entry will be created."                    
                }
                
                $p.Mode = 'EventLog'
                $p.Source  = $Source
                $p.LogName = $LogName
            }
            
            'LogToFile' {
                if (-not (Test-Path -Path $FilePath)) {
                    Write-Verbose "Log file $FilePath does not exist. Attempting to create the file..."
                    try {
                        $directory = Split-Path -Path $FilePath -Parent
                        if (-not (Test-Path -Path $directory)) {
                            Write-Verbose "Creating parent directory $directory"
                            $null = New-Item -Path $directory -ItemType Directory -Force
                        }
                        
                        $null = New-Item -Path $FilePath -ItemType File -Force
                    }
                    catch [System.Exception] {
                        $err = $_
                        throw "Unable to access path ${FilePath}: $err"
                    }
                }
                else {
                    Write-Verbose "Log file $FilePath already exists."
                }
                
                $p.Mode = 'File'
                $p.FilePath = $FilePath
            }
        }
    }
    
    end {
        
        # Update PrivateData again
        Set-ModulePrivateData -PrivateData $p
        
    }
}
