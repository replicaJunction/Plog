function Invoke-LogCleanupSimple {
    [CmdletBinding()]
    param()
    
    begin {
        # Constants
        if (-not $script:regexDate) {
            # Regex to get the date out of a log file name
            $script:regexDate = '^.*_(?<date>\d{4}-\d{2}-\d{2}-\d{4})\.log$'
        }
        
        if (-not $script:fileDateFormat) {
            $script:fileDateFormat = 'yyyy-MM-dd-HHmm'
        }
        
        $p = Get-ModulePrivateData
        
        # Files must be newer than x days old
        $dateCutoff = [DateTime]::Today.AddDays(-$p.History.Days)
        
        $currentLogFile = Get-LogFileName -ScriptName (Split-Path -Path $MyInvocation.ScriptName -Leaf)
        $logDir = Split-Path -Path $currentLogFile -Parent
        $logBaseName = ((Split-Path -Path $currentLogFile -Leaf) -split '_')[0] # Remove the date stamp
    }
    
    process {
        $logFiles = Get-ChildItem -Path $logDir -Filter "$logBaseName*.log"
        foreach ($file in $logFiles) {
            Write-Debug "Invoke-LogCleanupSimple: processing file $($file.FullName)"
            
            # Get the date out of the filename using a named group in the regex
            # and PowerShell's automatic $Matches variable
            if ($file.Name -match $script:regexDate) {
                # Parse the text date as a DateTime
                $thisDate = [DateTime]::ParseExact($Matches.date, $script:fileDateFormat, [System.Globalization.CultureInfo]::CurrentCulture)
                
                Write-Debug "Invoke-LogCleanupSimple: file date is [$thisDate]"
                
                if ($thisDate -ge $dateCutoff) {
                    Write-Debug "Invoke-LogCleanupSimple: file is less than $($p.History.Days) days old, so it will not be deleted"
                }
                else {
                    Write-Debug "Invoke-LogCleanupSimple: file is older than $($p.History.Days) days old; deleting"
                    Remove-Item -Path $file.FullName -Force
                }
            }
            else {
                Write-Debug "Invoke-LogCleanupSimple: unknown file [$file] will be removed"
                Remove-Item -Path $file.FullName -Force
            }
        }
    }
}
