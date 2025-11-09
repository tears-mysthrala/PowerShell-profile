# Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/

function Clear-RecycleBin {
  #1# Removing recycle bin files
  # Set the path to the recycle bin on the C drive
  $Path = 'C' + ':\$Recycle.Bin'
  # Get all items (files and directories) within the recycle bin path, including hidden ones
  Write-Verbose "[INFO] Cleaning recycle bin with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue |
  # Remove the items, excluding any files with the .ini extension
  Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue
  # Display a success message
  Write-Verbose "All the necessary data removed from recycle bin successfully" -ForegroundColor Green
}

function Clear-TempData {
  #2# Remove Temp files from various locations
  Write-Verbose "Erasing temporary files from various locations" -ForegroundColor Yellow
  # Specify the path where temporary files are stored in the Windows Temp folder
  $Path1 = 'C' + ':\Windows\Temp'
  # Remove all items (files and directories) from the Windows Temp folder
  Write-Verbose "[INFO] Cleaning Windows Temp folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Specify the path where temporary files are stored in the Windows Prefetch folder
  $Path2 = 'C' + ':\Windows\Prefetch'
  # Remove all items (files and directories) from the Windows Prefetch folder
  Write-Verbose "[INFO] Cleaning Windows Prefetch folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Specify the path where temporary files are stored in the user's AppData\Local\Temp folder
  $Path3 = 'C' + ':\Users\*\AppData\Local\Temp'
  # Remove all items (files and directories) from the specified user's Temp folder
  Write-Verbose "[INFO] Cleaning user Temp folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Display a success message
  Write-Verbose "removed all the temp files successfully" -ForegroundColor Green
}

function Clear-Disk {
  #3# Using Disk cleanup Tool
  # Display a message indicating the usage of the Disk Cleanup tool
  Write-Verbose "Using Disk cleanup Tool" -ForegroundColor Yellow
  # Run the Disk Cleanup tool with the specified sagerun parameter
  cleanmgr /sagerun:1 | out-Null
  # Emit a beep sound using ASCII code 7
  Write-Verbose "$([char]7)"
  # Display a success message indicating that Disk Cleanup was successfully done
  Write-Verbose "Disk Cleanup Successfully done" -ForegroundColor Green
}

function Clear-All {
  Clear-RecycleBin
  Delete-TempData
  Run-DiskCleanUp
}
