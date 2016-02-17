function Get-LogFileName {
    [CmdletBinding()]
    param(
        # Numeric suffix to use
        [int] $Suffix = -1
    )
    
    begin {
        $p = Get-ModulePrivateData
        
        # Use a script-wide variable for performance
        if ($script:fileDateFormat -eq $null) {
            $script:fileDateFormat = 'yyyymmdd-HHmm'
        }
    }
    
    process {
        if ($p.Mode -eq 'File') {
            $i = $p.FileName.LastIndexOf('.')
        
            $basename = $p.FileName.substring(0, $i)
            $extension = $p.FileName.substring($i) # includes the dot, i.e. .log
                
            if ($p.FileNameUseTimestamp -and $Suffix -gt -1) {
                $fileName = '{0}_{1}_{2}{3}' -f $basename, (Get-Date -Format $script:fileDateFormat), $Suffix, $extension
            }
            elseif ($p.FileNameUseTimestamp) {
                $fileName = '{0}_{1}{2}' -f $basename, (Get-Date -Format $script:fileDateFormat), $extension
            }
            elseif ($Suffix -gt -1) {
                $fileName = '{0}_{1}{2}' -f $basename, $Suffix, $extension
            }               
            else {
                $fileName = $p.FileName
            } 
            
            $fullName = Join-Path -Path $p.Directory -ChildPath $fileName
            Write-Output $fullName
        }
        else {
            Write-Debug "Not in File mode, so there is no filename for logging"
        }
    }
}
