$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe "Get-LogFileName" {
        $dateFormat = 'yyyy-MM-dd-HHmm'
    
        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{
                Mode = 'Simple'
            } 
        }
    
        Mock Get-ModulePrivateData { $privateData }
        
        # Name of this script file, without the .ps1 extension.
        # MyInvocation.MyCommand.Path and MyInvocation.ScriptName do weird
        # things inside Pester.
        $scriptName = 'Get-LogFileName.Tests'
        
        Mock Write-Debug { Write-Host $Message -ForegroundColor Cyan }
        
        # We're going to mock Get-Date to ensure that there's no millisecond difference
        # between the test and the function.
        $dateConstant = Get-Date -Format $dateFormat 
        Mock Get-Date -ParameterFilter {$Format -eq $dateFormat} { $dateConstant }
        
        $output = Get-LogFileName
        $expectedFilename = 'TestDrive:\dir\{0}_{1}.log' -f $scriptName, $dateConstant
        
        It 'Gets a log file name with the current script name a date and timestamp' {    
            $output | Should Be $expectedFilename
        }
        
        It 'Creates the log directory if it does not exist' {
            'TestDrive:\dir' | Should Exist
        }
        
        It 'Uses a cached log file for performance' {
            # Change a setting that would produce a different filename
            $privateData.History = @{
                Mode = 'StructuredFolder'
            }
            
            Get-LogFileName | Should Be $expectedFilename 
        }
        
        $oldOutput = $output
        $output = Get-LogFileName -Force
        $expectedFilename = 'TestDrive:\dir\{0}\{0}_{1}.log' -f $scriptName, $dateConstant
        
        It 'Supports the -Force switch to generate a new filename' {
            $output | Should Not Be $oldOutput
        }
        
        It 'Returns a filename in a subfolder if History.Mode is set to StructuredFolder' {
            $expectedFilename = 'TestDrive:\dir\{0}\{0}_{1}.log' -f $scriptName, $dateConstant
            $output | Should Be $expectedFilename
        }
        
        It 'Accepts a -ScriptName parameter to provide an alternate script name' {
            $expectedFilename = 'TestDrive:\dir\{0}\{0}_{1}.log' -f 'MyScript001', $dateConstant
            Get-LogFileName -ScriptName 'MyScript001' -Force | Should Be $expectedFilename
        }
    }
}
