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
    Write-Error -Message 'Git is not installed on your system.' -Category NotInstalled
    Read-Host
    Exit 127
}

Write-Verbose -Message "Git found: $($git.Source)"





# Ask the user for the folder to watch
Add-Type -AssemblyName System.Windows.Forms
$folderDialog = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
$folderDialog.Description = 'Choose a folder to watch for changes.'

if (!($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)) {
    Write-Host -ForegroundColor DarkRed 'Cancelled. Have a nice day...'
    Read-Host
    Exit
}

Write-Host -ForegroundColor Cyan "Started to Watch $($folderDialog.SelectedPath)"
