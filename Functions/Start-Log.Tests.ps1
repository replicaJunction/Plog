$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

InModuleScope "Plog" {
    Describe "Start-Log" {
        $filePath = "TestDrive:\temp.log"

        Mock Get-ModulePrivateData {
            Write-Output @{}
        }
        
        Mock Set-ModulePrivateData {
            # Export what would be set to the PrivateData FilePath variable
            $PrivateData.FilePath
        }

        It 'Saves the log file path to module PrivateData using Set-ModulePrivateData' {
            Start-Log -FilePath $filePath | Should Be $filePath
            Assert-MockCalled -CommandName Get-ModulePrivateData -Scope It -Times 1 -Exactly
            Assert-MockCalled -CommandName Set-ModulePrivateData -Scope It -Times 1 -Exactly
        }
        
        It 'Creates the file if it does not exist' {
            Remove-Item -Path $filePath -Force
            Start-Log -FilePath $filePath
            $filePath | Should Exist
        }
        
        It 'Deletes all content of the existing file if the -Clear parameter is passed' {
            Set-Content -Value 'abc123' -Path $filePath
            Start-Log -FilePath $filePath -Clear
            $filePath | Should Exist
            Get-Content $filePath | Should BeNullOrEmpty
        }
    }
}