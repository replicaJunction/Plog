$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope 'Plog' {
    Describe "Get-LogFileName" {
        $dateFormat = 'yyyyMMdd-HHmm'
    
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
        Mock Get-Date -ParameterFilter {$Format -eq $dateFormat} {
            $dateConstant
        }
        
        It 'Gets a log file name with the current script name a date and timestamp' {
            $expectedFilename = 'TestDrive:\dir\{0}_{1}.log' -f $scriptName, $dateConstant
            Get-LogFileName | Should Be $expectedFilename
        }
        
        It 'Returns a filename in a subfolder if History.Mode is set to StructuredFolder' {
            # Remove script scoped variable
            Remove-Variable -Name currentLogFile -Scope Script
            
            $privateData.History = @{
                Mode = 'StructuredFolder'
            }
            
            $expectedFilename = 'TestDrive:\dir\{0}\{0}_{1}.log' -f $scriptName, $dateConstant
            Get-LogFileName | Should Be $expectedFilename
        }
        
        It 'Accepts a -ScriptName parameter to provide an alternate script name' {
            # Remove script scoped variable
            Remove-Variable -Name currentLogFile -Scope Script
            
            $expectedFilename = 'TestDrive:\dir\{0}\{0}_{1}.log' -f 'MyScript001', $dateConstant
            Get-LogFileName -ScriptName 'MyScript001' | Should Be $expectedFilename
        }
        
        It 'Creates the log file directory if necessary' {
            
        }
    }
}