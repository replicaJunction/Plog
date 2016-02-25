#Requires -Module Plog
[CmdletBinding()]
param()

# Plog init
Set-LogMode -Path C:\Logs

Write-Log "Test"

Write-Log "Test warning" -Severity Warning

Write-Log "Test error" -Severity Error

Write-Log "Complete"
