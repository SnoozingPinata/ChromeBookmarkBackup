# To use this command, create a folder in this directory "C:\Program Files\WindowsPowerShell\Modules" with the name "ChromeBookmarkBackup".
# Next, Save this file in that folder with the title ChromeBookmarkBackup.psm1
# Now you should be able to open a powershell window and just tiype "Backup-ChromeBookmark" and you will have a backup located in "C:\ChromeBookmarksBackup"

function Backup-ChromeBookmarks {
    # This is currently the default path for Chrome bookmarks. Can be edited if Google updates the default location. Pulls the username from the environment variable.
    $filePath = "C:\Users\$($env:UserName)\AppData\Local\Google\Chrome\User Data\Default\bookmarks"

    # This is the folder that the bookmarks are moved to. 
    $backupFilePath = "C:\ChromeBookmarksBackup"

    # This builds the file name with the current date. Have to change the format that Get-Date outputs so it doesn't have a ':' in it which is not allowed in paths.
    $destinationFileName = "$(Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }) Bookmarks"

    # This is complete file path of the new bookmarks file.
    $destinationPath = ($($backupFilePath) + '\' + $($destinationFileName))

    # Checks for the destination folder, and creates it if it doesn't fine it initially. Loops back on itself until it is validated.
    [bool] $destinationPathValidated = $false
    Do {
        Write-Output "Testing Destination Path...`n"
        if (Get-Item -Path $backupFilePath) {
            $destinationPathValidated = $true
            Write-Output "Destination path found at: $($backupFilePath)`n"
        } else {
            Write-Output "Destination path not found. Creating destination folder at: $($backupFilePath) `n"
            New-Item -Path "C:\" -Name "ChromeBookmarksBackup" -ItemType "directory" -Force
        }
    } While ($destinationPathValidated = $false)

    # Checks for the Bookmarks file and begins the copy. Does validation and lets user know if it worked or not. Closes program either way.
    if (Get-Item -Path $filePath) {
        Copy-Item -Path $filePath -Destination $destinationPath
        If (Get-Item -Path $destinationPath) {
            Write-Output "Backup Successful.`n"
        }
        Read-Host -Prompt "Backup Process has finished. Press Enter to close."
    } else {
        Write-Output "Could not find the bookmarks file. It is possible Google has moved the file after an update.`n"
        Read-Host -Prompt "Verify Chrome is not open and try running the backup script again. Press Enter to close."
    }
    Exit
}
