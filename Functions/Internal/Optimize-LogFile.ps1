﻿function Optimize-LogFile {
    [CmdletBinding()]
    param()
    
    begin {
        $p = Get-ModulePrivateData
    }
    
    process {
        $existingFile = Get-Item -Path (Get-LogFileName)
        if ($existingFile.Length -gt $p.MaxSize) {
            Write-Debug "Plog: Optimizing log file"
            
            # Find a new filename that doesn't exist OR try until the file
            # history limit is reached.
            [int] $suffix = 0
            $oldFilename = Get-LogFileName -Suffix $suffix
            while ((Test-Path -Path $oldFilename) -and -not ($p.MaxHistory -and ($suffix + 1 -ge $p.MaxHistory))) { 
                $suffix++
                $oldFilename = Get-LogFileName -Suffix $suffix
            }
            
            if ($p.MaxHistory -and ($suffix + 1 -ge $p.MaxHistory)) {
                Write-Debug "Plog: Maximum history limit reached ($($p.MaxHistory)). File $oldFilename should be deleted."
                Remove-Item -Path $oldFilename -Force
            }
            else {
                Write-Debug "Plog: Found available file name $oldFilename (suffix: $suffix)"
            }
            
            # Now rename each file down the line until _0 is available.
            # $suffix doesn't exist due to the while loop above, so start at $suffix - 1
            for ($i = $suffix; $i -gt 0; $i--) {
                Write-Debug "Plog: Moving item $(Get-LogFileName -Suffix ($i - 1)) to $(Get-LogFileName -Suffix $i)"
                Move-Item -Path (Get-LogFileName -Suffix ($i - 1)) -Destination (Get-LogFileName -Suffix $i)
            }
            
            # Finally, rename the most recent log file to _0
            Write-Debug "Plog: Moving item $existingFile to $(Get-LogFileName -Suffix 0)"
            Move-Item -Path $existingFile -Destination (Get-LogFileName -Suffix 0)
        }
    }
}
