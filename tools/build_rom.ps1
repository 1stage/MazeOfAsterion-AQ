# PowerShell script to build Aquarius ROM from separate regions
# Usage: powershell -ExecutionPolicy RemoteSigned -File build_rom.ps1

$lowRomAsm = "src/low_rom.asm"
$highRomAsm = "src/high_rom.asm"
$scrambleAsm = "src/scramblecode.asm"
$titleScreen = "src/title_screen.scr"

$lowRomBin = "low_rom.bin"
$highRomBin = "high_rom.bin"
$scrambleBin = "scramblecode.bin"
$scrBin = "title_screen.scr"
$outRom = "aquarius.rom"

# Assemble low ROM ($c000-$d7ff, 6144 bytes)
z80asm -b $lowRomAsm
if (!(Test-Path $lowRomBin)) { $lowRomBin = $lowRomAsm.Replace(".asm", ".bin") }
# Pad to 6144 bytes
$bytes = [System.IO.File]::ReadAllBytes($lowRomBin)
if ($bytes.Length -lt 6144) {
    $pad = New-Object byte[](6144 - $bytes.Length)
    [System.IO.File]::WriteAllBytes($lowRomBin, $bytes + $pad)
}

# SCR file ($d800-$dfff, 2048 bytes)
if (!(Test-Path $scrBin)) { Copy-Item $titleScreen $scrBin }
$bytes = [System.IO.File]::ReadAllBytes($scrBin)
if ($bytes.Length -lt 2048) {
    $pad = New-Object byte[](2048 - $bytes.Length)
    [System.IO.File]::WriteAllBytes($scrBin, $bytes + $pad)
}

# Assemble scramblecode ($e000-$e00f, 16 bytes)
z80asm -b $scrambleAsm
if (!(Test-Path $scrambleBin)) { $scrambleBin = $scrambleAsm.Replace(".asm", ".bin") }
$bytes = [System.IO.File]::ReadAllBytes($scrambleBin)
if ($bytes.Length -lt 16) {
    $pad = New-Object byte[](16 - $bytes.Length)
    [System.IO.File]::WriteAllBytes($scrambleBin, $bytes + $pad)
}

# Assemble high ROM ($e010-$ffff, 8176 bytes)
z80asm -b $highRomAsm
if (!(Test-Path $highRomBin)) { $highRomBin = $highRomAsm.Replace(".asm", ".bin") }
$bytes = [System.IO.File]::ReadAllBytes($highRomBin)
if ($bytes.Length -lt 8176) {
    $pad = New-Object byte[](8176 - $bytes.Length)
    [System.IO.File]::WriteAllBytes($highRomBin, $bytes + $pad)
}

# Concatenate all regions
Write-Host "Concatenating regions to $outRom..."
$final = [System.IO.File]::ReadAllBytes($lowRomBin) +
         [System.IO.File]::ReadAllBytes($scrBin) +
         [System.IO.File]::ReadAllBytes($scrambleBin) +
         [System.IO.File]::ReadAllBytes($highRomBin)
[System.IO.File]::WriteAllBytes($outRom, $final)
Write-Host "ROM build complete: $outRom"
