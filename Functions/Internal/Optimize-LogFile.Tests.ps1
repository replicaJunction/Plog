$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe 'Optimize-LogFile' {
        $privateData = @{
            Mode       = 'File'
            Cleanup    = $true
            Directory  = 'TestDrive:\'
            FileName   = 'pester.log' 
            MaxSize    = 50
            MaxHistory = 5
        }
    
        Mock Get-ModulePrivateData {
            $privateData
        }
        
        Mock Write-Debug {
            Write-Host $Message -ForegroundColor Cyan
        }
        
        It 'Creates a new log file if the old one exceeds the configured size' {
            # Create a file bigger than 500 bytes
            New-Item -Path 'TestDrive:\pester.log' -ItemType 'File' | Out-Null
            Set-Content -Path 'TestDrive:\pester.log' -Value ("." * 200)
            { Optimize-LogFile } | Should Not Throw
        }
        
        It 'Writes no data to the original log file' {
            # Original file should no longer exist 
            'TestDrive:\pester.log' | Should Not Exist
        }
        
        It 'Only renames log files once' {
            # Next numbered file in the sequence should now exist.
            # Function should only rename once, even if the older file is above
            # the configured size limit.
            'TestDrive:\pester_0.log' | Should Exist
            'TestDrive:\pester_1.log' | Should Not Exist
        }
        
        It 'Renames all additional history files as necessary' {
            Set-Content -Path 'TestDrive:\pester.log' -Value ("." * 200)
            { Optimize-LogFile } | Should Not Throw
            
            # Now 0 and 1 should both exist
            'TestDrive:\pester_0.log' | Should Exist
            'TestDrive:\pester_1.log' | Should Exist
            'TestDrive:\pester_2.log' | Should Not Exist
        }
    }
}