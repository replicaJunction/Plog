function Get-LogFileName {
    [CmdletBinding()]
    param()
    
    begin {
        $p = Get-ModulePrivateData
        
        # Use a script-wide variable for performance
        if ($script:fileDateFormat -eq $null) {
            $script:fileDateFormat = 'yyyymmdd-HHmm'
        }
    }
    
    process {
        if ($p.Mode -eq 'File') {
            if (-not $script:logFileName) {
                if ($p.FileNameUseTimestamp) {
                    $i = $p.FileName.LastIndexOf('.')
            
                    $basename = $p.FileName.substring(0, $i)
                    $extension = $p.FileName.substring($i) # includes the dot, i.e. .log
                    
                    $fileName = '{0}_{1}{2}' -f $basename, (Get-Date -Format $script:fileDateFormat), $extension
                    
                    $fullName = Join-Path -Path $p.Directory -ChildPath $fileName
                }
                else {
                    $fullName = Join-Path -Path $p.Directory -ChildPath $p.FileName
                }
                
                $script:logFileName = $fullName
            }
            
            Write-Output $script:logFileName
        }
        else {
            Write-Debug "Not in File mode, so there is no filename for logging"
        }
    }
}
