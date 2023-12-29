Write-Host -ForegroundColor DarkGreen '  ____ _ _    __        __    _       _               '
Write-Host -ForegroundColor DarkGreen ' / ___(_) |_  \ \      / /_ _| |_ ___| |__   ___ _ __ '
Write-Host -ForegroundColor DarkGreen '| |  _| | __|  \ \ /\ / / _` | __/ __| ''_ \ / _ \ ''__|'
Write-Host -ForegroundColor DarkGreen '| |_| | | |_    \ V  V / (_| | || (__| | | |  __/ |   '
Write-Host -ForegroundColor DarkGreen ' \____|_|\__|    \_/\_/ \__,_|\__\___|_| |_|\___|_|   '
Write-Host
Write-Host





# Check if git is installed on the system
$git = Get-Command -Name git -ErrorAction SilentlyContinue

if (!$git) {
    Write-Error -Message 'Git is not installed on your system.' -Category NotInstalled -ErrorAction Stop
}

Write-Verbose -Message "Git found: $($git.Source)"





# Ask the user for the folder to watch
Add-Type -AssemblyName System.Windows.Forms
$folderDialog = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
$folderDialog.Description = 'Choose a folder to watch for changes.'

if ($folderDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host -ForegroundColor DarkRed 'Cancelled. Have a nice day...'
    Exit
}

$gitTopLevel = Resolve-Path (& $git.Source -C $folderDialog.SelectedPath rev-parse --show-toplevel 2>&1 | Out-String).Trim()

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
            Write-Host -ForegroundColor Blue (& $git.Source -C $folderDialog.SelectedPath init 2>&1 | Out-String).Trim()
        }
        1 {
            Write-Error -Message "$($folderDialog.SelectedPath) is not a git repository." -Category NotEnabled -ErrorAction Stop
        }
    }

}
else {
    if ($gitTopLevel.Path -ne $folderDialog.SelectedPath) {
        Write-Error -Message "The folder $($folderDialog.SelectedPath) is not the git toplevel folder. Use $($gitTopLevel.Path) instead." -Category InvalidArgument -ErrorAction Stop
    }
}

Write-Host -ForegroundColor Cyan "Started to Watch $($folderDialog.SelectedPath)"
