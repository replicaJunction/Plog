$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe 'Set-LogHistoryMode' {
        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{} 
        }
    
        Mock Get-ModulePrivateData { $privateData }
        Mock Set-ModulePrivateData { $privateData }
        
        Mock Write-Debug { Write-Host $Message -ForegroundColor Cyan }
        
        It 'Updates module PrivateData with the provided history mode' {
            $output = Set-LogHistoryMode -Mode 'Simple'
            $output.History.Mode | Should Be 'Simple'
        }
        
        It 'Correctly handles positional parameters' {
            $output = Set-LogHistoryMode 'StructuredFolder'
            $output.History.Mode | Should Be 'StructuredFolder'
        }
    }
}