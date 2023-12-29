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
