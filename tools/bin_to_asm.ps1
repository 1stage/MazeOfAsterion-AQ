#!/usr/bin/env pwsh
# Binary to ASM Converter
# Converts a binary file into assembly language data statements

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "",
    
    [Parameter(Mandatory=$false)]
    [string]$LabelName = "data",
    
    [Parameter(Mandatory=$false)]
    [int]$BytesPerLine = 16,
    
    [Parameter(Mandatory=$false)]
    [string]$Format = "db",  # db, dw, defb, defw
    
    [Parameter(Mandatory=$false)]
    [string]$HexPrefix = "$",  # $, 0x, &h
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeComments,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeSize,
    
    [Parameter(Mandatory=$false)]
    [string]$OrgAddress = ""
)

function Show-Help {
    Write-Host "Binary to ASM Converter" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\bin_to_asm.ps1 -InputFile <file> [options]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -InputFile     : Input binary file (required)"
    Write-Host "  -OutputFile    : Output ASM file (default: input_name.asm)"
    Write-Host "  -LabelName     : Label name for the data (default: 'data')"
    Write-Host "  -BytesPerLine  : Bytes per line (default: 16)"
    Write-Host "  -Format        : Data format: db, dw, defb, defw (default: db)"
    Write-Host "  -HexPrefix     : Hex prefix: $, 0x, &h (default: $)"
    Write-Host "  -IncludeComments : Add ASCII comments"
    Write-Host "  -IncludeSize   : Include size information"
    Write-Host "  -OrgAddress    : Include ORG directive with address"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\bin_to_asm.ps1 -InputFile data.bin"
    Write-Host "  .\bin_to_asm.ps1 -InputFile sprite.bin -LabelName sprite_data -BytesPerLine 8"
    Write-Host "  .\bin_to_asm.ps1 -InputFile font.bin -IncludeComments -OrgAddress '$c000'"
}

# Validate input file
if (-not (Test-Path $InputFile)) {
    Write-Error "Input file '$InputFile' not found!"
    Show-Help
    exit 1
}

# Generate output filename if not provided
if ($OutputFile -eq "") {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $OutputFile = "$baseName.asm"
}

# Read binary data
try {
    $binaryData = [System.IO.File]::ReadAllBytes($InputFile)
    Write-Host "Read $($binaryData.Length) bytes from '$InputFile'" -ForegroundColor Green
} catch {
    Write-Error "Failed to read input file: $_"
    exit 1
}

# Start building ASM content
$asmContent = @()

# Add header comment
$asmContent += "; Generated from binary file: $InputFile"
$asmContent += "; Created on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$asmContent += "; File size: $($binaryData.Length) bytes"
$asmContent += ""

# Add ORG directive if specified
if ($OrgAddress -ne "") {
    $asmContent += "org $OrgAddress"
    $asmContent += ""
}

# Add size constant if requested
if ($IncludeSize) {
    $asmContent += "${LabelName}_size equ $($binaryData.Length)"
    $asmContent += ""
}

# Add main label
$asmContent += "${LabelName}:"

# Convert bytes to assembly
for ($i = 0; $i -lt $binaryData.Length; $i += $BytesPerLine) {
    $lineBytes = @()
    $asciiComment = ""
    
    # Get bytes for this line
    $endIndex = [Math]::Min($i + $BytesPerLine - 1, $binaryData.Length - 1)
    
    for ($j = $i; $j -le $endIndex; $j++) {
        $byte = $binaryData[$j]
        
        # Format hex value based on prefix
        switch ($HexPrefix) {
            "$" { $hexValue = "`$$($byte.ToString('x2'))" }
            "0x" { $hexValue = "0x$($byte.ToString('x2'))" }
            "&h" { $hexValue = "&h$($byte.ToString('x2'))" }
            default { $hexValue = "`$$($byte.ToString('x2'))" }
        }
        
        $lineBytes += $hexValue
        
        # Build ASCII comment if requested
        if ($IncludeComments) {
            if ($byte -ge 32 -and $byte -le 126) {
                $asciiComment += [char]$byte
            } else {
                $asciiComment += "."
            }
        }
    }
    
    # Build the line
    $dataLine = "    $Format " + ($lineBytes -join ", ")
    
    # Add ASCII comment if enabled
    if ($IncludeComments -and $asciiComment -ne "") {
        $dataLine += "    ; $asciiComment"
    }
    
    $asmContent += $dataLine
}

# Add end label if size is included
if ($IncludeSize) {
    $asmContent += ""
    $asmContent += "${LabelName}_end:"
}

# Write output file
try {
    $asmContent | Out-File -FilePath $OutputFile -Encoding ASCII
    Write-Host "Successfully created '$OutputFile'" -ForegroundColor Green
    Write-Host "Data label: '$LabelName'" -ForegroundColor Cyan
    Write-Host "Format: $Format with $HexPrefix prefix" -ForegroundColor Cyan
    Write-Host "$($binaryData.Length) bytes converted" -ForegroundColor Cyan
} catch {
    Write-Error "Failed to write output file: $_"
    exit 1
}

# Show sample of output
Write-Host ""
Write-Host "Sample output:" -ForegroundColor Yellow
$sampleLines = $asmContent | Select-Object -First 10
$sampleLines | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
if ($asmContent.Length -gt 10) {
    Write-Host "  ..." -ForegroundColor Gray
}