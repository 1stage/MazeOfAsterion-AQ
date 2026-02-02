#!/usr/bin/env powershell
<#
.SYNOPSIS
    Checks free bytes (0x00 padding) in a binary ROM file.

.DESCRIPTION
    Reads a binary file and verifies that a specified address range contains
    only 0x00 bytes. Useful for tracking available free space in ROM builds.

.PARAMETER FilePath
    Path to the binary file to check. Defaults to build/asterion.bin

.PARAMETER StartAddress
    Hexadecimal start address (e.g., 0x3d70). Defaults to 0x3d70

.PARAMETER EndAddress
    Hexadecimal end address (e.g., 0x3eff). Defaults to 0x3eff

.EXAMPLE
    .\check-free-bytes.ps1
    # Checks asterion.bin from 0x3d70 to 0x3eff (default)

.EXAMPLE
    .\check-free-bytes.ps1 -StartAddress 0x3d00 -EndAddress 0x3eff
    # Checks from 0x3d00 to 0x3eff

.EXAMPLE
    .\check-free-bytes.ps1 -FilePath "path\to\rom.bin" -StartAddress 0x2000 -EndAddress 0x2100
    # Checks a different file and address range
#>

param(
    [string]$FilePath = "build\asterion.bin",
    [string]$StartAddress = "0x0000",
    [string]$EndAddress = "0x3fff"
)

# Convert hex strings to integers
$start = [Convert]::ToInt32($StartAddress, 16)
$end = [Convert]::ToInt32($EndAddress, 16)
$length = $end - $start

# Verify file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "ERROR: File not found: $FilePath" -ForegroundColor Red
    exit 1
}

# Read binary file
try {
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
} catch {
    Write-Host "ERROR: Failed to read file: $_" -ForegroundColor Red
    exit 1
}

# Verify address range is valid
if ($end -gt $bytes.Length) {
    Write-Host "ERROR: End address 0x$($end.ToString('X4')) exceeds file size (0x$($bytes.Length.ToString('X4')))" -ForegroundColor Red
    exit 1
}

# Find runs of 0x00 bytes greater than 4 bytes
$runs = @()
$i = $start
while ($i -lt $end) {
    if ($bytes[$i] -eq 0) {
        $runStart = $i
        $runLength = 0
        while ($i -lt $end -and $bytes[$i] -eq 0) {
            $runLength++
            $i++
        }
        if ($runLength -gt 4) {
            $runs += @{
                Start = $runStart
                Length = $runLength
                End = $runStart + $runLength - 1
            }
        }
    } else {
        $i++
    }
}

# Calculate total free bytes from runs > 4
$totalFree = ($runs | Measure-Object -Property Length -Sum).Sum
if ($null -eq $totalFree) { $totalFree = 0 }

# Display results
Write-Host ""
Write-Host "Free Space Analysis (runs > 4 bytes)" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "File:         $FilePath"
Write-Host "Range:        0x$($start.ToString('X4')) to 0x$($end.ToString('X4'))"
Write-Host "Total Range:  $length bytes"
Write-Host "Free Bytes:   $totalFree (in runs > 4 bytes)"
Write-Host "Runs Found:   $($runs.Count)"
Write-Host ""

if ($runs.Count -gt 0) {
    Write-Host "Free Runs:" -ForegroundColor Green
    $runTotal = 0
    foreach ($run in $runs) {
        Write-Host "  0x$($run.Start.ToString('X4')) - 0x$($run.End.ToString('X4')): $($run.Length) bytes"
        $runTotal += $run.Length
    }
    Write-Host "  ---------------------------" -ForegroundColor Green
    Write-Host "            TOTAL: $runTotal bytes" -ForegroundColor Green
} else {
    Write-Host "No contiguous free runs > 4 bytes found." -ForegroundColor Yellow
}
Write-Host ""
