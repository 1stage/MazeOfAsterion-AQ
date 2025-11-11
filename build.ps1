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

# Clean previous build if requested
if ($Clean) {
    Write-Status "Cleaning previous build files..." -Color $Yellow
    $FilesToClean = @("$BuildFolder\*", "src\*.lis", "src\*.map", "src\*.o")
    foreach ($Pattern in $FilesToClean) {
        Get-ChildItem $Pattern -ErrorAction SilentlyContinue | Remove-Item -Force
    }
}

# Get file size
$FileInfo = Get-Item (Join-Path $BuildFolder $OutputBin)
$FileSizeKB = [math]::Round($FileInfo.Length / 1024, 2)
Write-Status "Generated $OutputBin ($($FileInfo.Length) bytes / ${FileSizeKB}KB)" -Color $Green

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