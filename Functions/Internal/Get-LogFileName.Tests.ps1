$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    
    $dateFormat = 'yyyymmdd-HHmm'
    
    Describe "Get-LogFileName" {
        # We're going to mock Get-Date to ensure that there's no millisecond difference
        # between the test and the function.
        $dateConstant = Get-Date -Format $dateFormat 
        Mock Get-Date -ParameterFilter {$Format -eq $dateFormat} {
            $dateConstant
        }
        
        Mock Get-ModulePrivateData {
            @{
                Mode      = 'File'
                Directory = 'TestDrive:\dir'
                FileName  = 'test.log' 
            }
        }
       
        It 'Gets a timestamped log file name with the current date' {
            $expectedFilename = 'TestDrive:\dir\test_{0}.log' -f $dateConstant
            Get-LogFileName | Should Be $expectedFilename 
        }
    }
}