$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope "Plog" {
    Describe "Write-Log" {
        $filePath = "TestDrive:\temp.log"

        $privateData = @{
            Mode    = 'File'
            Path    = 'TestDrive:\dir'
            History = @{
                Mode = 'Simple'
            }
        }
        
        Mock Get-ModulePrivateData { $privateData }
            
        Context 'Logging to file' {
            Mock Get-LogFileName { $filePath }
            
            $output = Write-Log -Message 'Test'
            
            It 'Uses Get-ModulePrivateData to obtain log settings' {
                Assert-MockCalled -CommandName Get-ModulePrivateData -Scope Context -Times 1 -Exactly
            }
            
            It 'Uses Get-LogFileName to obtain the fully qualified path to the log file' {
                Assert-MockCalled -CommandName Get-LogFileName -Scope Context -Times 1 -Exactly
            }

            It 'Creates the log file if it does not exist' {
                # Should have been created by the tests above
                $filePath | Should Exist
            }
            
            It 'Produces no output' {
                $output | Should BeNullOrEmpty
            }
        }

        Context 'Logging to event log' {
            $privateData = @{
                Mode    = 'EventLog'
                LogName = 'Windows PowerShell'
                Source  = 'PowerShell' 
            }
            
            Mock Write-EventLog { 
                @{
                    LogName   = $LogName
                    Source    = $Source
                    EventID   = $EventID
                    EntryType = $EntryType
                    Message   = $Message
                }
             }
            
            $output = Write-Log -Message 'Test'
            
            It 'Uses Write-EventLog to write the log message to the event log' {
                $output.LogName | Should Be 'Windows PowerShell'
                $output.Source | Should Be 'PowerShell'
                $output.EventID | Should Be 1001
                $output.EntryType | Should Be 'Information'  
            }
            
            It 'Logs different entry types for different Severity values' {
                (Write-Log -Message 'Test information').EntryType | Should Be 'Information'
                (Write-Log -Message 'Test warning' -Severity Warning).EntryType | Should Be 'Warning'
                (Write-Log -Message 'Test error' -Severity Error).EntryType | Should Be 'Error'
            }
        }
        
        Context 'Write-Host testing' { 
            
            Mock Write-Host {
                @{
                    Message         = $Object
                    ForegroundColor = $ForegroundColor
                    BackgroundColor = $BackgroundColor
                }
            }
            
            
            It 'Produces output to Write-Host if the WriteHost value is set' {
                $privateData.WriteHost = $true
                $output = Write-Log -Message 'Test'
                Assert-MockCalled -CommandName Write-Host -Scope It -Times 1 -Exactly
                $output.ForegroundColor | Should Be $host.PrivateData.VerboseForegroundColor
                $output.BackgroundColor | Should Be $host.PrivateData.VerboseBackgroundColor
            }
            
            It 'Does not write output via Write-Host if WriteHost is not set' {
                $privateData.WriteHost = $false
                $output = Write-Log -Message 'Test'
                Assert-MockCalled -CommandName Write-Host -Scope It -Times 0 -Exactly
            }
        }
        
        Context 'Error checking' {
            It 'Throws an error if logging options have not been initialized' {
                $privateData = @{}
                { Write-Log -Message 'Test' } | Should Throw 'Logging options are undefined. You must call Set-LogMode first.'
            }
        }
    }
}