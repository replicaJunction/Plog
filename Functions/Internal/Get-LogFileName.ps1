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
        $i = $p.FileName.LastIndexOf('.')
        
        $basename = $p.FileName.substring(0, $i)
        $extension = $p.FileName.substring($i) # includes the dot, i.e. .log
        
        $fileName = '{0}_{1}{2}' -f $basename, (Get-Date -Format $script:fileDateFormat), $extension
        
        $fullName = Join-Path -Path $p.Directory -ChildPath $fileName
        
        Write-Output $fullName
    }
}
