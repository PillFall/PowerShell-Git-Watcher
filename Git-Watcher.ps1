Write-Host -ForegroundColor DarkGreen '  ____ _ _    __        __    _       _               '
Write-Host -ForegroundColor DarkGreen ' / ___(_) |_  \ \      / /_ _| |_ ___| |__   ___ _ __ '
Write-Host -ForegroundColor DarkGreen '| |  _| | __|  \ \ /\ / / _` | __/ __| ''_ \ / _ \ ''__|'
Write-Host -ForegroundColor DarkGreen '| |_| | | |_    \ V  V / (_| | || (__| | | |  __/ |   '
Write-Host -ForegroundColor DarkGreen ' \____|_|\__|    \_/\_/ \__,_|\__\___|_| |_|\___|_|   '
Write-Host
Write-Host





# Check if git is installed on the system
$global:git = Get-Command -Name git -ErrorAction SilentlyContinue

if (!$global:git) {
    Write-Error -Message 'Git is not installed on your system.' -Category NotInstalled -ErrorAction Stop
}

Write-Verbose -Message "Git found: $($global:git.Source)"





# Ask the user for the folder to watch
Add-Type -AssemblyName System.Windows.Forms
$global:folderDialog = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
$global:folderDialog.Description = 'Choose a folder to watch for changes.'

if ($global:folderDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host -ForegroundColor DarkRed 'Cancelled. Have a nice day...'
    Exit
}

$gitTopLevel = Resolve-Path (& $global:git.Source -C $global:folderDialog.SelectedPath rev-parse --show-toplevel 2>&1 | Out-String).Trim() -ErrorAction SilentlyContinue

if ($LastExitCode -ne 0) {
    switch (
        $host.UI.PromptForChoice(
            'Not a Git repository',
            'Want to create a new repository?',
            @(
                [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Create a new repository and continue.")
                [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Cancel the creation and stops.")
            ),
            0
        )
    ) {
        0 {
            Write-Host -ForegroundColor Blue (& $global:git.Source -C $global:folderDialog.SelectedPath init 2>&1 | Out-String).Trim()
        }
        1 {
            Write-Error -Message "$($global:folderDialog.SelectedPath) is not a git repository." -Category NotEnabled -ErrorAction Stop
        }
    }

}
else {
    if ($gitTopLevel.Path -ne $global:folderDialog.SelectedPath) {
        Write-Error -Message "The folder $($global:folderDialog.SelectedPath) is not the git toplevel folder. Use $($gitTopLevel.Path) instead." -Category InvalidArgument -ErrorAction Stop
    }
}





$watcher = New-Object -TypeName System.IO.FileSystemWatcher
$watcher.Path = $global:folderDialog.SelectedPath
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$CommitChangesToGit = {
    if ($Event.SourceEventArgs.Name -match '^.git/?.*') {
        Return
    }

    if (Test-Path -Path $Event.SourceEventArgs.FullPath -PathType Container) {
        Return
    }

    Write-Host "[$($Event.TimeGenerated)] $($Event.SourceEventArgs.Name) $($Event.SourceEventArgs.ChangeType)"
    & $global:git.Source -C $global:folderDialog.SelectedPath add $Event.SourceEventArgs.Name
    & $global:git.Source -C $global:folderDialog.SelectedPath commit -m "$($Event.SourceEventArgs.Name) $($Event.SourceEventArgs.ChangeType)"
}

Register-ObjectEvent -InputObject $watcher -EventName 'Created' -Action $CommitChangesToGit | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName 'Changed' -Action $CommitChangesToGit | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName 'Renamed' -Action $CommitChangesToGit | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName 'Deleted' -Action $CommitChangesToGit | Out-Null

Write-Host -ForegroundColor Cyan "Started to Watch $($global:folderDialog.SelectedPath)"

try {
    while ($true) {
        & $global:git.Source -C $global:folderDialog.SelectedPath rev-parse 2>&1 | Out-Null
        if (!(Test-Path -Path $global:folderDialog.SelectedPath -PathType Container) -or $LastExitCode -ne 0) {
            Exit
        }
        Start-Sleep -Seconds 10
    }
}
finally {
    $watcher.Dispose()
    Write-Host -ForegroundColor DarkRed 'Stopping...'
}
