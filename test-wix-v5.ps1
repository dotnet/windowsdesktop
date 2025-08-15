#!/usr/bin/env pwsh
#
# Test script for WiX v5 functionality in WindowsDesktop repository
#

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('restore', 'build', 'pack', 'all', 'validate', 'installers')]
    [string]$Action = 'all',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    
    [Parameter(Mandatory=$false)]
    [switch]$CleanFirst
)

$ErrorActionPreference = 'Stop'

# Define colors for output
$Red = @{ ForegroundColor = 'Red' }
$Green = @{ ForegroundColor = 'Green' }
$Yellow = @{ ForegroundColor = 'Yellow' }
$Cyan = @{ ForegroundColor = 'Cyan' }

function Write-Section {
    param([string]$Title)
    Write-Host "`n=== $Title ===" @Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" @Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" @Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" @Red
}

function Test-WixV5Setup {
    Write-Section "Validating WiX v5 Setup"
    
    # Check if local feed is configured
    $nugetConfig = Get-Content "NuGet.config" -Raw
    if ($nugetConfig -match "local-arcade-wix-v5") {
        Write-Success "Local Arcade WiX v5 feed is configured"
        
        # Check if the local feed directory exists
        if (Test-Path "C:\local-packages\arcade-wix-v5") {
            $packageCount = (Get-ChildItem "C:\local-packages\arcade-wix-v5" -Filter "*.nupkg" | Measure-Object).Count
            if ($packageCount -gt 0) {
                Write-Success "Found $packageCount package(s) in local feed"
            } else {
                Write-Warning "Local feed directory exists but no packages found"
            }
        } else {
            Write-Warning "Local feed directory C:\local-packages\arcade-wix-v5 does not exist"
        }
    } else {
        Write-Error "Local Arcade WiX v5 feed not found in NuGet.config"
        return $false
    }
    
    # Check global.json versions
    $globalJson = Get-Content "global.json" -Raw | ConvertFrom-Json
    $arcadeVersion = $globalJson.'msbuild-sdks'.'Microsoft.DotNet.Arcade.Sdk'
    if ($arcadeVersion -like "*dev*") {
        Write-Success "global.json is using WiX v5 Arcade version: $arcadeVersion"
    } else {
        Write-Warning "global.json version: $arcadeVersion"
    }
    
    # Check Version.Details.props versions
    $versionDetails = Get-Content "eng\Version.Details.props" -Raw
    if ($versionDetails -match "10\.0\.0-dev") {
        Write-Success "Version.Details.props is using WiX v5 versions"
    } else {
        Write-Warning "Version.Details.props may not be using WiX v5 versions"
    }
    
    return $true
}

function Invoke-BuildStep {
    param(
        [string]$StepName,
        [string]$Command,
        [string[]]$Arguments
    )
    
    Write-Section $StepName
    
    $fullCommand = "$Command $($Arguments -join ' ')"
    Write-Host "Executing: $fullCommand" @Cyan
    
    try {
        $startTime = Get-Date
        & $Command @Arguments
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$StepName completed successfully in $($duration.TotalMinutes.ToString('F1')) minutes"
            return $true
        } else {
            Write-Error "$StepName failed with exit code $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-Error "$StepName failed with exception: $($_.Exception.Message)"
        return $false
    }
}

function Test-WixOutputs {
    Write-Section "Validating WiX v5 Installer Outputs"
    
    $artifactsDir = "artifacts"
    if (-not (Test-Path $artifactsDir)) {
        Write-Warning "Artifacts directory not found - build may not have completed"
        return $false
    }
    
    $foundOutputs = $false
    
    # Look for MSI files
    $msiFiles = Get-ChildItem -Path $artifactsDir -Filter "*.msi" -Recurse
    if ($msiFiles.Count -gt 0) {
        Write-Success "Found $($msiFiles.Count) MSI file(s):"
        foreach ($msi in $msiFiles) {
            Write-Host "  - $($msi.FullName)" @Cyan
        }
        $foundOutputs = $true
    }
    
    # Look for bundle executables
    $bundleFiles = Get-ChildItem -Path $artifactsDir -Filter "*windowsdesktop-runtime*.exe" -Recurse
    if ($bundleFiles.Count -gt 0) {
        Write-Success "Found $($bundleFiles.Count) bundle file(s):"
        foreach ($bundle in $bundleFiles) {
            Write-Host "  - $($bundle.FullName)" @Cyan
        }
        $foundOutputs = $true
    }
    
    # Look for wixpack files
    $wixpackFiles = Get-ChildItem -Path $artifactsDir -Filter "*.wixpack.zip" -Recurse
    if ($wixpackFiles.Count -gt 0) {
        Write-Success "Found $($wixpackFiles.Count) wixpack file(s):"
        foreach ($wixpack in $wixpackFiles) {
            Write-Host "  - $($wixpack.FullName)" @Cyan
        }
        $foundOutputs = $true
    }
    
    if (-not $foundOutputs) {
        Write-Warning "No MSI, bundle, or wixpack files found in artifacts"
        Write-Host "This may be expected if you only ran restore/build without pack" @Yellow
    }
    
    return $foundOutputs
}

# Main execution
Write-Host "WindowsDesktop WiX v5 Test Script" @Cyan
Write-Host "Configuration: $Configuration" @Cyan
Write-Host "Action: $Action" @Cyan

$startTime = Get-Date
$success = $true

try {
    # Validate setup first
    if (-not (Test-WixV5Setup)) {
        throw "WiX v5 setup validation failed"
    }
    
    # Execute requested actions
    switch ($Action) {
        'validate' {
            Write-Success "WiX v5 validation completed"
        }
        'restore' {
            $success = Invoke-BuildStep "Package Restore" ".\eng\common\build.cmd" @("-restore", "-configuration", $Configuration)
        }
        'build' {
            $success = Invoke-BuildStep "Build" ".\eng\common\build.cmd" @("-build", "-configuration", $Configuration)
        }
        'pack' {
            $success = Invoke-BuildStep "Pack" ".\eng\common\build.cmd" @("-pack", "-configuration", $Configuration)
        }
        'installers' {
            # Build installers specifically - includes restore, build, and pack
            $success = Invoke-BuildStep "Restore" ".\eng\common\build.cmd" @("-restore", "-configuration", $Configuration)
            if ($success) {
                $success = Invoke-BuildStep "Build" ".\eng\common\build.cmd" @("-build", "-configuration", $Configuration)
            }
            if ($success) {
                $success = Invoke-BuildStep "Pack Installers" ".\eng\common\build.cmd" @("-pack", "-configuration", $Configuration)
            }
        }
        'all' {
            $success = Invoke-BuildStep "Restore" ".\eng\common\build.cmd" @("-restore", "-configuration", $Configuration)
            if ($success) {
                $success = Invoke-BuildStep "Build" ".\eng\common\build.cmd" @("-build", "-configuration", $Configuration)
            }
            if ($success) {
                $success = Invoke-BuildStep "Pack" ".\eng\common\build.cmd" @("-pack", "-configuration", $Configuration)
            }
        }
    }
    
    # Test outputs if we built/packed
    if ($Action -in @('pack', 'all', 'installers') -and $success) {
        Test-WixOutputs
    }
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    $success = $false
}

$totalDuration = (Get-Date) - $startTime

Write-Section "Summary"
if ($success) {
    Write-Success "WiX v5 test completed successfully in $($totalDuration.TotalMinutes.ToString('F1')) minutes"
    
    if ($Action -in @('pack', 'all', 'installers')) {
        Write-Host "`nNext steps:" @Cyan
        Write-Host "1. Check artifacts/ directory for generated installers" @Cyan
        Write-Host "2. Test the MSI and bundle files on target machines" @Cyan
        Write-Host "3. Validate installer functionality and UI" @Cyan
        Write-Host "4. Look for WiX v5 specific features or improvements" @Cyan
    }
} else {
    Write-Error "WiX v5 test completed with errors in $($totalDuration.TotalMinutes.ToString('F1')) minutes"
}

exit $(if ($success) { 0 } else { 1 })
