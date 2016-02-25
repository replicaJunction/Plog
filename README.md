# What is Plog?

Plog is a simple PowerShell module designed to make logging easy, once and for all.

## Seriously, another logging framework?

Yes!

Plog started out as a personal project born out of my own needs. I needed a better way to log some of the long-running tasks I'd been working on, and Start-Transcript wasn't cutting it any more.  I was tired of researching every time I needed to remember the syntax for writing to the Event Log, or re-creating a logging function every time I needed the ability to log in another task. 

I wasn't able to find a single, all-in-one module that met my needs exactly, so I decided to write one.

## Plog goals

* **Simplicity.** Plog provides a simple, drop-in logging framework for PowerShell scripting without extra hassle. All you need is one "init" line, Set-LogMode, in each script where you'd like to use Plog.
* **Flexibility.** Plog can write to a configurable log file or a Windows event log.
* **Readability**. Plog produces log files designed for CMTrace, taking full advantage of the same logging methods used by System Center Configuration Manager. Log files include timestamps and script line number.

## What about performance?

Plog is designed to optimizee perfromance wherever possible. At the end of the day, though, performance is not the primary goal of the Plog module. Plog is about making your (well, my) life easier as a PowerShell scripter / admin by providing a unified, flexible logging framework to PowerShell scripts.

When writing log files, Plog uses the Add-Content cmdlet in PowerShell, which is known to have worse perfermance than some .NET classes for filesystem access. This is because Add-Content doesn't leave a file lock on the log file. This approach also doesn't require the user to manually initialize or complete the log file.

Plog does provide support for an alternate, "high performance" mode, where it uses a StreamWriter object instead of the Add-Content cmdlet. This adds a little bit of complexity to the script, but is still fairly manageable. See below for usage instructions.

If you have performance suggestions or enhancements, please feel free to contribute them via issues or pull requests. I'm all for maximizing performance as long as it doesn't conflict with the above goals of the Plog project.

# How do I use Plog?

## Basic usage

1. Install Plog to your PSModulePath. I will add Plog to the PowerShell Gallery if there is sufficient demand for it.
2. At the start of a script where you'd like to use Plog, use Set-LogMode to define how you'd like Plog to log output.
3. Anywhere you'd like to log output, simply use Write-Log instead of Write-Verbose or similar.

```powershell
# Log to a file and display output in the console
Set-LogMode -Path C:\Logs
Write-Log "MyVar value is $myVar"
```

```powershell
# Log an error to the Windows PowerShell event log, without any console output
Set-LogMode -EventLog -WriteHost $false
Write-Log "Something broke!" -Severity Error
```

## High performance mode

To enable high performance mode, you'll need a Start-Log at the start of your script and a Stop-Log at the end. The log file will have a file lock on it for the duration of your script.

```powershell
Set-LogMode -Path C:\Logs
Start-Log
Write-Log "Plog is using high performance mode."

# Script logic...

Write-Log "All done with my script."
Stop-Log
```

## Cleaning up log files

Plog can optionally organize your log history, preserving log files for a configurable length of time.

There are two history modes available to Plog, configurable via Set-LogHistoryMode:

**Simple:** Plog keeps any log files dated today, and also keeps any files dated X days older than today (where X is the -Days parameter to Set-LogHistoryMode).

```powershell
# Keep log files from today and 2 previous days
Set-LogHistoryMode -Mode Simple -Days 2
```

**StructuredFolder:** Plog creates a folder structure for your log files.

* Log files from today are left in the root of the log directory.
* Log files from the last X days are copied to a "daily" subdirectory of the log path.
* One log file per week for the last X weeks is copied to a "weekly" subdirectory of the log path.
  * The day of the week is expressed as an int from 1 to 7, where 1 is Sunday, 2 is Monday, and so on.
* One log file per month for the last X months is copied to a "monthly" subdirectory of the log path.
  * The day of the month is also configurable. This is limited to the 28th for compatibility with February.

```powershell
# Keep 7 days of log files, the last 4 Mondays, and the first day of the last 3 months
Set-LogHistoryMode -Mode StructuredFolder -Days 7 -Weeks 4 -DayOfWeek 2 -Months 3 -DayOfMonth 1

# Keep 14 days of log files, the last 8 Fridays, and the 15th day of the last 6 months
Set-LogHistoryMode -Mode StructuredFolder -Days 14 -Weeks 8 -DayOfWeek 6 -Months 6 -DayOfMonth 15
```

To clean up log history produced by Plog, simply run Invoke-LogCleanup. It is suggested to place this at the end of your script, rather than the beginning.

If you are using high performance mode, you must call Stop-Log first before Invoke-LogCleanup, as this mode keeps a file lock on the log file.

# Planned features

* Ability to write a plain text log instead of CMTrace format (a.k.a a boring log file)
* Saving Plog settings to a configuration file to allow them to persist across PowerShell sessions

# Credits

Plog would not be possible without some of the great posts from [#PSBlogWeek 2016](https://twitter.com/hashtag/PSBlogWeek). I'd especially like to thank Adam Bertram for information on CMTrace's logging template, as well as the method for logging the script line number. [Check out the full blog post](http://www.adamtheautomator.com/building-logs-for-cmtrace-powershell/) for more details.
