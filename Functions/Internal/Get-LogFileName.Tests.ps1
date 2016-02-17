$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    
    $dateFormat = 'yyyymmdd-HHmm'
    
    $privateData = @{
        Mode      = 'File'
        Directory = 'TestDrive:\dir'
        FileName  = 'test.log' 
    }
    
    Describe "Get-LogFileName" {
        Mock Get-ModulePrivateData {
            $privateData
        }
        
        # We're going to mock Get-Date to ensure that there's no millisecond difference
        # between the test and the function.
        $dateConstant = Get-Date -Format $dateFormat 
        Mock Get-Date -ParameterFilter {$Format -eq $dateFormat} {
            $dateConstant
        }
        
        It 'Gets a log file name' {
            $expectedFilename = 'TestDrive:\dir\test.log' -f $dateConstant
            Get-LogFileName | Should Be $expectedFilename
        }
        
        It 'Gets a log file name with a timestamp if FileNameUseTimestamp is true' {
            $privateData.FileNameUseTimestamp = $true
            # Remove the script-wide variable used for performance 
            Remove-Variable -Name logFileName -Scope Script
            $expectedFilename = 'TestDrive:\dir\test_{0}.log' -f $dateConstant
            Get-LogFileName | Should Be $expectedFilename 
        }
    }
}