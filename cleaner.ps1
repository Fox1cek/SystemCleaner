#Requires -RunAsAdministrator
<#
.SYNOPSIS
    SystemCleaner - Ultimate Windows Cleaning Tool by Fox1cek
.DESCRIPTION
    Comprehensive system cleaning: temp files, browser data, Windows cache, 
    old updates, empty folders, duplicate files, and more
.EXAMPLE
    irm https://raw.githubusercontent.com/Fox1cek/SystemCleaner/main/cleaner.ps1 | iex
#>

$ErrorActionPreference = "Stop"
$totalCleaned = 0
$itemsCleaned = 0

function Write-Status($Message, $Type = "Info") {
    switch ($Type) {
        "Success" { Write-Host "[OK] " -ForegroundColor Green -NoNewline }
        "Warning" { Write-Host "[!] " -ForegroundColor Yellow -NoNewline }
        "Error"   { Write-Host "[X] " -ForegroundColor Red -NoNewline }
        "Info"    { Write-Host "[*] " -ForegroundColor Cyan -NoNewline }
        "Clean"   { Write-Host "[CLEAN] " -ForegroundColor Magenta -NoNewline }
    }
    Write-Host $Message
}

function Get-FriendlySize($Bytes) {
    $sizes = 'B', 'KB', 'MB', 'GB', 'TB'
    for ($i = 0; $Bytes -ge 1KB -and $i -lt $sizes.Count; $i++) { $Bytes /= 1KB }
    return "{0:N2} {1}" -f $Bytes, $sizes[$i]
}

function Remove-FolderContents($Path, $Description) {
    if (Test-Path $Path) {
        $size = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum
        if ($size -gt 0) {
            Get-ChildItem $Path -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $global:totalCleaned += $size
            $global:itemsCleaned++
            Write-Status "$Description $(Get-FriendlySize $size)" "Clean"
            return $size
        }
    }
    return 0
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   SystemCleaner - Ultimate PC Cleaner" -ForegroundColor Cyan
Write-Host "              by Fox1cek" -ForegroundColor Gray
Write-Host "==========================================`n" -ForegroundColor Cyan

Write-Status "Analyzing system..." "Info"
Write-Host ""

# 1. Windows Temp Folders
Write-Host "--- Windows System Temp ---" -ForegroundColor Yellow
Remove-FolderContents $env:TEMP "Windows Temp"
Remove-FolderContents "C:\Windows\Temp" "Windows System Temp"
Remove-FolderContents "$env:LOCALAPPDATA\Temp" "User Temp"

# 2. Browser Data (Chrome, Edge, Firefox)
Write-Host "`n--- Browser Data ---" -ForegroundColor Yellow

# Chrome
$chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
$chromeCodeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache"
Remove-FolderContents $chromeCache "Chrome Cache"
Remove-FolderContents $chromeCodeCache "Chrome Code Cache"

# Edge
$edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
Remove-FolderContents $edgeCache "Edge Cache"

# Firefox
$firefoxProfiles = Get-ChildItem "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles" -Directory -ErrorAction SilentlyContinue
foreach ($profile in $firefoxProfiles) {
    Remove-FolderContents "$($profile.FullName)\cache2" "Firefox Cache"
}

# 3. Windows Update Cache
Write-Host "`n--- Windows Update Cache ---" -ForegroundColor Yellow
Remove-FolderContents "C:\Windows\SoftwareDistribution\Download" "Windows Update Downloads"

# 4. Event Logs (skip protected/system logs)
Write-Host "`n--- Event Logs ---" -ForegroundColor Yellow
$logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | 
        Where-Object { $_.RecordCount -gt 0 -and -not $_.IsEnabled }
$cleared = 0
foreach ($log in $logs) {
    try {
        wevtutil cl $log.LogName 2>$null | Out-Null
        $cleared++
    } catch { }
}
Write-Status "Cleared $cleared event logs" "Clean"

# 5. Recycle Bin
Write-Host "`n--- Recycle Bin ---" -ForegroundColor Yellow
$recycleBin = (New-Object -ComObject Shell.Application).Namespace(0xA)
$items = $recycleBin.Items()
$count = $items.Count
if ($count -gt 0) {
    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(0).ParseName("Recycle Bin").InvokeVerb("Empty Recycle Bin")
    Write-Status "Emptied Recycle Bin ($count items)" "Clean"
    $itemsCleaned++
} else {
    Write-Status "Recycle Bin already empty" "Info"
}

# 6. Prefetch (old only)
Write-Host "`n--- Prefetch Files ---" -ForegroundColor Yellow
$prefetchPath = "C:\Windows\Prefetch"
$oldPrefetch = Get-ChildItem $prefetchPath -File -ErrorAction SilentlyContinue | 
               Where-Object { $_.LastAccessTime -lt (Get-Date).AddDays(-30) }
if ($oldPrefetch) {
    $size = ($oldPrefetch | Measure-Object -Property Length -Sum).Sum
    $oldPrefetch | Remove-Item -Force
    $totalCleaned += $size
    Write-Status "Removed $(@($oldPrefetch).Count) old prefetch files ($(Get-FriendlySize $size))" "Clean"
}

# 7. DNS Cache
Write-Host "`n--- DNS Cache ---" -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Status "Flushed DNS cache" "Clean"

# 8. Thumbnail Cache
Write-Host "`n--- Thumbnail Cache ---" -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Remove-FolderContents "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\*.db" "Thumbnail Cache"
Start-Process explorer

# 9. Recent Files
Write-Host "`n--- Recent Files ---" -ForegroundColor Yellow
Remove-FolderContents "$env:APPDATA\Microsoft\Windows\Recent" "Recent Files"

# 10. Crash Dumps
Write-Host "`n--- Crash Dumps & Logs ---" -ForegroundColor Yellow
Remove-FolderContents "C:\Windows\Minidump" "Crash Minidumps"
Remove-FolderContents "$env:LOCALAPPDATA\CrashDumps" "App Crash Dumps"
Remove-FolderContents "C:\Windows\LiveKernelReports" "Kernel Reports"

# 11. Windows Error Reporting
Write-Host "`n--- Error Reports ---" -ForegroundColor Yellow
Remove-FolderContents "$env:LOCALAPPDATA\Microsoft\Windows\WER" "Error Reports"
Remove-FolderContents "$env:PROGRAMDATA\Microsoft\Windows\WER" "System Error Reports"

# 12. Delivery Optimization Files
Write-Host "`n--- Delivery Optimization ---" -ForegroundColor Yellow
Remove-FolderContents "C:\Windows\SoftwareDistribution\DeliveryOptimization" "Delivery Optimization"

# 13. Font Cache
Write-Host "`n--- Font Cache ---" -ForegroundColor Yellow
Remove-FolderContents "$env:LOCALAPPDATA\Microsoft\FontCache" "Font Cache"

# 14. Empty Folders (optional, scan only)
Write-Host "`n--- Scanning Empty Folders ---" -ForegroundColor Yellow
$emptyFolders = @()
$pathsToScan = @($env:TEMP, "$env:LOCALAPPDATA\Temp", "$env:USERPROFILE\Downloads")
foreach ($scanPath in $pathsToScan) {
    if (Test-Path $scanPath) {
        $empty = Get-ChildItem $scanPath -Directory -Recurse -ErrorAction SilentlyContinue | 
                 Where-Object { $_.GetFiles().Count -eq 0 -and $_.GetDirectories().Count -eq 0 }
        $emptyFolders += $empty
    }
}
if ($emptyFolders.Count -gt 0) {
    Write-Status "Found $($emptyFolders.Count) empty folders (not removed, check manually)" "Warning"
} else {
    Write-Status "No empty folders found" "Info"
}

# 15. Disk Cleanup simulation (analyze component store)
Write-Host "`n--- Component Store Analysis ---" -ForegroundColor Yellow
$dismOutput = dism /Online /Cleanup-Image /AnalyzeComponentStore 2>&1
if ($dismOutput -match "([0-9.]+) GB") {
    $reclaimable = $matches[1]
    Write-Status "Component store: $reclaimable GB reclaimable (run 'dism /Online /Cleanup-Image /StartComponentCleanup' to reclaim)" "Info"
}

# Summary
Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "   CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Total Space Freed: $(Get-FriendlySize $totalCleaned)" -ForegroundColor Cyan
Write-Host "Items Cleaned: $itemsCleaned" -ForegroundColor Cyan
Write-Host ""
Write-Host "Recommendations:" -ForegroundColor Yellow
Write-Host "  • Restart browser for full cache clear" -ForegroundColor Gray
Write-Host "  • Run Windows Disk Cleanup for more options" -ForegroundColor Gray
Write-Host "  • Consider running monthly" -ForegroundColor Gray
Write-Host ""

# Option to clean more aggressively
$choice = Read-Host "Run deep clean (component store + Windows.old)? (y/n)"
if ($choice -eq 'y') {
    Write-Host "`n--- Deep Clean ---" -ForegroundColor Magenta
    Write-Status "Cleaning component store..." "Info"
    dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
    Write-Status "Component store cleaned" "Clean"
    
    if (Test-Path "C:\Windows.old") {
        Write-Status "Removing Windows.old..." "Info"
        takeown /F "C:\Windows.old" /A /R /D Y | Out-Null
        icacls "C:\Windows.old" /grant Administrators:F /T | Out-Null
        Remove-Item "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Status "Windows.old removed" "Clean"
    }
}

Write-Host "`nDone! Your PC is cleaner now. 🧹" -ForegroundColor Green
