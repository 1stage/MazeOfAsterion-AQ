#!/usr/bin/env pwsh
# Build script for MazeOfAsterion-AQ
# Compiles ASM files, renames output, and copies to multiple destinations

param(
    [switch]$Verbose,
    [switch]$Clean
)

# Configuration
$ProjectName = "asterion"
$SourceFile = "src\asterion.asm"
$BuildFolder = "build"
$OutputBin = "asterion.bin"
$OutputRom = "asterion.rom"
$RomBaseAddress = 0xC000
$ScrambleStartAddress = 0xE000

# Get AQPLUS_EMU_DISK environment variable
$AqplusEmuDisk = $env:AQPLUS_EMU_DISK
if (-not $AqplusEmuDisk) {
    Write-Warning "AQPLUS_EMU_DISK environment variable not set"
}

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

function Write-Status {
    param($Message, $Color = "White")
    Write-Host "[BUILD] $Message" -ForegroundColor $Color
}

function Test-DirectoryExists {
    param($Path)
    if (-not (Test-Path $Path)) {
        try {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Status "Created directory: $Path" -Color $Yellow
        } catch {
            Write-Status "Failed to create directory: $Path" -Color $Red
            return $false
        }
    }
    return $true
}

# Start build process
Write-Status "Starting build for $ProjectName" -Color $Cyan
Write-Status "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Color $Cyan

# Ensure build directory exists
if (-not (Test-DirectoryExists $BuildFolder)) {
    Write-Status "Failed to create build directory" -Color $Red
    exit 1
}

# Clean previous build if requested
if ($Clean) {
    Write-Status "Cleaning previous build files..." -Color $Yellow
    $FilesToClean = @("$BuildFolder\*", "src\*.lis", "src\*.map", "src\*.o")
    foreach ($Pattern in $FilesToClean) {
        Get-ChildItem $Pattern -ErrorAction SilentlyContinue | Remove-Item -Force
    }
}

# Check if source file exists
if (-not (Test-Path $SourceFile)) {
    Write-Status "Source file not found: $SourceFile" -Color $Red
    exit 1
}

# Compile the assembly file
Write-Status "Compiling $SourceFile..." -Color $Yellow

$CompileArgs = @("-b", $SourceFile, "-l", "-m")
if ($Verbose) {
    Write-Status "Running: z80asm $($CompileArgs -join ' ')" -Color $Cyan
}

try {
    $Result = & z80asm @CompileArgs 2>&1
    $ExitCode = $LASTEXITCODE
    
    if ($Verbose -and $Result) {
        Write-Host $Result
    }
    
    if ($ExitCode -ne 0) {
        Write-Status "Compilation failed with exit code $ExitCode" -Color $Red
        if ($Result) {
            Write-Host $Result -ForegroundColor $Red
        }
        exit $ExitCode
    }
    
    Write-Status "Compilation successful!" -Color $Green
} catch {
    Write-Status "Compilation error: $_" -Color $Red
    exit 1
}

# Check if output file was created (z80asm creates it in the src directory)
$OutputBinSrc = "src\$OutputBin"
if (-not (Test-Path $OutputBinSrc)) {
    Write-Status "Output file not found: $OutputBinSrc" -Color $Red
    exit 1
}

# Move output files to build folder
Write-Status "Moving output files to build folder..." -Color $Yellow

try {
    # Move the main binary file from src to build
    Move-Item $OutputBinSrc (Join-Path $BuildFolder $OutputBin) -Force
    Write-Status "Moved $OutputBin to build folder" -Color $Green
    
    # Move listing, map, and object files if they exist
    $ListFile = $SourceFile -replace '\.asm$', '.lis'
    $MapFile = $SourceFile -replace '\.asm$', '.map'
    $ObjectFile = $SourceFile -replace '\.asm$', '.o'
    
    if (Test-Path $ListFile) {
        Move-Item $ListFile (Join-Path $BuildFolder (Split-Path $ListFile -Leaf)) -Force
        Write-Status "Moved listing file to build folder" -Color $Green
    }
    
    if (Test-Path $MapFile) {
        Move-Item $MapFile (Join-Path $BuildFolder (Split-Path $MapFile -Leaf)) -Force
        Write-Status "Moved map file to build folder" -Color $Green
    }
    
    if (Test-Path $ObjectFile) {
        Move-Item $ObjectFile (Join-Path $BuildFolder (Split-Path $ObjectFile -Leaf)) -Force
        Write-Status "Moved object file to build folder" -Color $Green
    }
    
} catch {
    Write-Status "Failed to move files to build folder: $_" -Color $Red
    exit 1
}

# Preserve unencrypted output, then scramble build binary
$BuildBinPath = Join-Path $BuildFolder $OutputBin
$UnencryptedBinPath = Join-Path $BuildFolder "asterion_unencrypted.bin"

Write-Status "Saving unencrypted copy: $UnencryptedBinPath" -Color $Yellow
Copy-Item $BuildBinPath $UnencryptedBinPath -Force

Write-Status "Calculating scramble byte..." -Color $Yellow
$SeedFile = "src\asterion.inc"
if (-not (Test-Path $SeedFile)) {
    Write-Status "Seed file not found: $SeedFile" -Color $Red
    exit 1
}

$SeedMap = @{}
foreach ($Line in Get-Content $SeedFile) {
    if ($Line -match "SCRAMBLE_SEED_(\d)\s+EQU\s+'(.)'") {
        $SeedMap[[int]$Matches[1]] = [byte][char]$Matches[2]
    }
}

$MissingSeeds = 0..6 | Where-Object { -not $SeedMap.ContainsKey($_) }
if ($MissingSeeds.Count -gt 0) {
    Write-Status "Missing SCRAMBLE_SEED bytes: $($MissingSeeds -join ', ')" -Color $Red
    exit 1
}

$SeedBytes = 0..6 | ForEach-Object { $SeedMap[$_] }
$SeedText = -join ($SeedBytes | ForEach-Object { [char]$_ })
$SeedSum = ($SeedBytes | Measure-Object -Sum).Sum
$ConstSum = 0x9c + 0xb0 + 0x6c + 0x64 + 0xa8
$SumE003E00E = $SeedSum + $ConstSum
$Remainder = ($SumE003E00E + 78) % 256
$ScrambleByte = [byte]($Remainder -bxor 0x70)

Write-Status ("Scramble byte = 0x{0:X2}" -f $ScrambleByte) -Color $Cyan
Write-Status "Encrypting $BuildBinPath with XOR scramble byte..." -Color $Yellow

$BinContent = [System.IO.File]::ReadAllBytes($BuildBinPath)
$HeaderOffset = $ScrambleStartAddress - $RomBaseAddress
$HeaderSize = 0x10
if ($ScrambleByte -ne 0) {
    if ($HeaderOffset -ge $BinContent.Length) {
        Write-Status ("Header offset 0x{0:X4} exceeds binary size; skipping encryption." -f $HeaderOffset) -Color $Yellow
    } else {
        for ($i = 0; $i -lt $BinContent.Length; $i++) {
            if ($i -ge $HeaderOffset -and $i -lt ($HeaderOffset + $HeaderSize)) {
                continue
            }
            $BinContent[$i] = $BinContent[$i] -bxor $ScrambleByte
        }
        [System.IO.File]::WriteAllBytes($BuildBinPath, $BinContent)
        Write-Status "Encryption complete (payload updated)." -Color $Green
    }
    Write-Status ("ROM file is encrypted with code 0x{0:X2}" -f $ScrambleByte) -Color "Magenta"
} else {
    Write-Status "Scramble byte is $00; encryption skipped (no-op)." -Color $Green
    Write-Status "ROM file is unencrypted" -Color "White"
}

# Clean previous build if requested
if ($Clean) {
    Write-Status "Cleaning previous build files..." -Color $Yellow
    $FilesToClean = @("$BuildFolder\*", "src\*.lis", "src\*.map", "src\*.o")
    foreach ($Pattern in $FilesToClean) {
        Get-ChildItem $Pattern -ErrorAction SilentlyContinue | Remove-Item -Force
    }
}

# Get file size (encrypted output)
$FileInfo = Get-Item (Join-Path $BuildFolder $OutputBin)
$FileSizeKB = [math]::Round($FileInfo.Length / 1024, 2)
Write-Status "Generated $OutputBin ($($FileInfo.Length) bytes / ${FileSizeKB}KB)" -Color $Green

# Create 64KB ROM file (4 copies of asterion.bin)
Write-Status "Creating 64KB ROM file..." -Color $Yellow

try {
    $SourceBinPath = Join-Path $BuildFolder $OutputBin
    $Output64KPath = Join-Path $BuildFolder "asterion64.bin"
    
    # Read the source binary
    $BinContent = [System.IO.File]::ReadAllBytes($SourceBinPath)
    $BinSize = $BinContent.Length
    
    # Create array to hold 4 copies
    $Rom64KB = New-Object byte[] (64 * 1024)
    
    # Copy the binary 4 times
    for ($i = 0; $i -lt 4; $i++) {
        $Offset = $i * $BinSize
        [Array]::Copy($BinContent, 0, $Rom64KB, $Offset, $BinSize)
    }
    
    # Write the 64KB ROM file
    [System.IO.File]::WriteAllBytes($Output64KPath, $Rom64KB)
    
    $Rom64Size = (Get-Item $Output64KPath).Length
    $Rom64SizeKB = [math]::Round($Rom64Size / 1024, 2)
    Write-Status "Created asterion64.bin ($Rom64Size bytes / ${Rom64SizeKB}KB)" -Color $Green
} catch {
    Write-Status "Failed to create 64KB ROM: $_" -Color $Red
}

# Copy to AQPLUS_EMU_DISK directory and rename to .rom
if ($AqplusEmuDisk -and (Test-Path $AqplusEmuDisk)) {
    Write-Status "Copying to AQPLUS_EMU_DISK directory..." -Color $Yellow
    
    try {
        $SourcePath = Join-Path $BuildFolder $OutputBin
        $DestPath = Join-Path $AqplusEmuDisk $OutputRom
        
        Copy-Item $SourcePath $DestPath -Force
        Write-Status "Copied $OutputBin to $DestPath" -Color $Green
    } catch {
        Write-Status "Failed to copy to AQPLUS_EMU_DISK: $_" -Color $Red
    }
} else {
    if (-not $AqplusEmuDisk) {
        Write-Status "AQPLUS_EMU_DISK environment variable not set - skipping copy" -Color $Yellow
    } else {
        Write-Status "AQPLUS_EMU_DISK directory not found: $AqplusEmuDisk" -Color $Yellow
    }
}

# Generate build report
Write-Status "Build Summary:" -Color $Cyan
Write-Status "  Source: $SourceFile" -Color "White"
Write-Status "  Output: $BuildFolder\$OutputBin" -Color "White"
Write-Status "  Size: $($FileInfo.Length) bytes (${FileSizeKB}KB)" -Color "White"
if ($ScrambleByte -ne 0) {
    Write-Status "  Seed: $SeedText" -Color "Magenta"
    Write-Status ("  Scramble byte: 0x{0:X2}" -f $ScrambleByte) -Color "Magenta"
    Write-Status ("  ROM file is Encrypted (0x{0:X2})" -f $ScrambleByte) -Color "Magenta"
} else {
    Write-Status "  ROM file is Unencrypted" -Color "Cyan"
}

if (Test-Path (Join-Path $BuildFolder "asterion64.bin")) {
    $Rom64Info = Get-Item (Join-Path $BuildFolder "asterion64.bin")
    $Rom64SizeKB = [math]::Round($Rom64Info.Length / 1024, 2)
    Write-Status "  64KB ROM: $BuildFolder\asterion64.bin (${Rom64SizeKB}KB)" -Color "White"
}

if ($AqplusEmuDisk -and (Test-Path $AqplusEmuDisk)) {
    Write-Status "  Copied to: $AqplusEmuDisk\$OutputRom" -Color "White"
} else {
    Write-Status "  AQPLUS_EMU_DISK copy: Skipped" -Color "White"
}

# Check for listing, map, and object files in build folder
$ListFile = Join-Path $BuildFolder "asterion.lis"
$MapFile = Join-Path $BuildFolder "asterion.map"
$ObjectFile = Join-Path $BuildFolder "asterion.o"

if (Test-Path $ListFile) {
    Write-Status "  Listing: $ListFile" -Color "White"
}
if (Test-Path $MapFile) {
    Write-Status "  Map: $MapFile" -Color "White"
}
if (Test-Path $ObjectFile) {
    Write-Status "  Object: $ObjectFile" -Color "White"
}

Write-Status "Build completed successfully!" -Color $Green
exit 0