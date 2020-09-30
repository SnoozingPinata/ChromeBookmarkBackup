Function Backup-ChromeBookmarks {
    [CmdletBinding()]
    Param (
        # This is currently the default path for Chrome bookmarks. Can be edited if Google updates the default location. Pulls the username from the environment variable.
        [Parameter(
            Position=0)]
        [string] $BookmarkPath = "C:\Users\$($env:UserName)\AppData\Local\Google\Chrome\User Data\Default\bookmarks",

        # This is the folder that the bookmarks are moved to. 
        [Parameter(
            Position=1)]
        [string] $DestinationFolderPath = "C:\ChromeBookmarksBackup"
    )

    # This builds the file name with the current date. Have to change the format that Get-Date outputs with ForEach-Object because some characters are not allowed in paths.
    [string] $destinationFileName = "$(Get-Date -Format "dd/MM/yyyy HH:mm" | ForEach-Object { $_ -replace ":", "." } | ForEach-Object { $_ -replace "/", "." }) Bookmarks"

    # This joins the file name we generated with the path that was input by the user.
    [string] $destinationPath = ($($DestinationFolderPath) + '\' + $($destinationFileName))

    # Checks for the destination folder and if it can't find it, it creates it. Then it loops back to the validation again. 
    [bool] $destinationPathValidated = $false
    Do {
        Write-Verbose "Testing Destination Path."
        If (Test-Path -Path $DestinationFolderPath) {
            $destinationPathValidated = $true
            Write-Verbose "Destination path found at: $($DestinationFolderPath)"
        } Else {
            Write-Verbose "Destination path not found. Creating destination folder at: $($DestinationFolderPath)"
            New-Item -Path $($DestinationFolderPath) -ItemType "directory" -Force
        }
    } While ($destinationPathValidated = $false)

    # Checks for the Bookmarks file and begins the copy. Does validation and lets user know if it worked or not. Closes program either way.
    If (Get-Item -Path $BookmarkPath) {
        Copy-Item -Path $BookmarkPath -Destination $destinationPath
        If (Test-Path -Path $destinationPath) {
            Write-Verbose "Backup Successful."
        }
        Write-Verbose "Backup Process has completed."
    } Else {
        Write-Verbose "Could not find the source bookmarks file. Verify it is in $($BookmarkPath) and try again."
    }
}
