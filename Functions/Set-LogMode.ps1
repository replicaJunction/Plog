function Set-LogMode {
    [CmdletBinding(DefaultParameterSetName = 'LogToFile')]
    param(
        # Path to the log file to use
        [Parameter(ParameterSetName = 'LogToFile',
                   Mandatory = $true)]
        [String] $FilePath,
        
        # Maximum size for a single log file. If this is set, Plog will
        # automatically clean up larger files by creating a log history.
        [Parameter(ParameterSetName = 'LogToFile',
                   Mandatory = $false)]
        [long] $MaxSize,
        
        # Maximum number of log files to preserve if using MaxSize.
        [Parameter(ParameterSetName = 'LogToFile',
                   Mandatory = $false)]
        [int] $MaxHistory,
        
        # Do not add a timestamp to the filename
        [Parameter(ParameterSetName = 'LogToFile',
                   Mandatory = $false)]
        [bool] $FileNameUseTimestamp = $true,
        
        # Clear the contents of the current log file
        [Parameter(ParameterSetName = 'LogToFile',
                   Mandatory = $false)]
        [Switch] $Clear,
        
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
        [Switch] $NoTest,
        
        # Should the log contents also be displayed in the host window?
        [bool] $WriteHost = $true
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
                if ($Clear -and (Test-Path -Path $FilePath)) {
                    Write-Verbose "Clear was specified. Clearing current contents of log file $FilePath"
                    [void] (Remove-Item -Path $FilePath -Force)
                }
                
                $logDirectory = Split-Path -Path $FilePath -Parent
                $logFilename = Split-Path -Path $FilePath -Leaf
                
                if (-not (Test-Path -Path $FilePath)) {
                    Write-Verbose "Log file $FilePath does not exist. Attempting to create the file..."
                    try {
                        if (-not (Test-Path -Path $logDirectory)) {
                            Write-Verbose "Creating parent directory $logDirectory"
                            [void] (New-Item -Path $logDirectory -ItemType Directory -Force)
                        }
                        else {
                            Write-Verbose "Directory $logDirectory appears to exist already"
                        }
                        
                        [void] (New-Item -Path $FilePath -ItemType File -Force)
                    }
                    catch [System.Exception] {
                        $err = $_
                        throw "Unable to access path ${FilePath}: $err"
                    }
                }
                else {
                    Write-Verbose "Log file $FilePath already exists."
                }
                
                $p.Mode                 = 'File'
                $p.Directory            = $logDirectory
                $p.FileName             = $logFilename
                $p.FileNameUseTimestamp = $FileNameUseTimestamp
                $p.MaxSize              = $MaxSize
                $p.MaxHistory           = $MaxHistory
            }
        }
        
        $p.WriteHost = $WriteHost
    }
    
    end {
        
        # Update PrivateData again
        Set-ModulePrivateData -PrivateData $p
        
    }
}
