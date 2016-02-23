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
        
        $output = Set-LogHistoryMode -Mode StructuredFolder -Days 3 -Weeks 4 -DayOfWeek 5 -Months 6 -DayOfMonth 7
        
        It 'Updates module PrivateData with History.Mode' {
            $output.History.Mode | Should Be 'StructuredFolder'
        }
        
        It 'Updates module PrivateData with History.Days' {
            $output.History.Days | Should Be 3
        }
        
        It 'Updates module PrivateData with History.Weeks' {
            $output.History.Weeks | Should Be 4
        }
        
        It 'Updates module PrivateData with History.DayOfWeek' {
            $output.History.DayOfWeek | Should Be 5
        }
        
        It 'Updates module PrivateData with History.Months' {
            $output.History.Months | Should Be 6
        }
        
        It 'Updates module PrivateData with History.DayOfMonth' {
            $output.History.DayOfMonth | Should Be 7
        }
    }
}