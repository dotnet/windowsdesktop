#!/usr/bin/env pwsh
#
# Helper script to build Arcade WiX v5 locally and set up the package feed
#

param(
    [Parameter(Mandatory=$false)]
    [string]$ArcadeDirectory = "C:\arcade-wix-v5",
    
    [Parameter(Mandatory=$false)]
    [string]$LocalFeedDirectory = "C:\local-packages\arcade-wix-v5",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipClone,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$Green = @{ ForegroundColor = 'Green' }
$Yellow = @{ ForegroundColor = 'Yellow' }
$Red = @{ ForegroundColor = 'Red' }
$Cyan = @{ ForegroundColor = 'Cyan' }

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

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" @Cyan
}

function Write-Section {
    param([string]$Title)
    Write-Host "`n=== $Title ===" @Cyan
}

Write-Host "Arcade WiX v5 Local Build Helper" @Cyan
Write-Host "================================" @Cyan
Write-Host "Arcade Directory: $ArcadeDirectory" @Cyan
Write-Host "Local Feed: $LocalFeedDirectory" @Cyan
Write-Host "Configuration: $Configuration" @Cyan

try {
    # Step 1: Clone Arcade if needed
    if (-not $SkipClone) {
        Write-Section "Cloning Arcade WiX v5"
        
        if (Test-Path $ArcadeDirectory) {
            if ($Force) {
                Write-Warning "Removing existing Arcade directory"
                Remove-Item -Path $ArcadeDirectory -Recurse -Force
            } else {
                Write-Warning "Arcade directory already exists. Use -Force to overwrite or -SkipClone to skip"
                Write-Info "Directory: $ArcadeDirectory"
                $continue = Read-Host "Continue with existing directory? (y/N)"
                if ($continue -ne 'y' -and $continue -ne 'Y') {
                    exit 1
                }
            }
        }
        
        if (-not (Test-Path $ArcadeDirectory)) {
            Write-Info "Cloning https://github.com/PranavSenthilnathan/arcade.git (wix-v5 branch)..."
            git clone https://github.com/PranavSenthilnathan/arcade.git -b wix-v5 $ArcadeDirectory
            if ($LASTEXITCODE -ne 0) {
                throw "Git clone failed"
            }
            Write-Success "Arcade cloned successfully"
        }
    } else {
        Write-Section "Using Existing Arcade Directory"
        if (-not (Test-Path $ArcadeDirectory)) {
            throw "Arcade directory does not exist: $ArcadeDirectory"
        }
        Write-Success "Using existing Arcade directory"
    }
    
    # Step 2: Build Arcade
    Write-Section "Building Arcade"
    
    $originalLocation = Get-Location
    try {
        Set-Location $ArcadeDirectory
        
        Write-Info "Building Arcade with configuration: $Configuration"
        $buildCommand = ".\eng\common\build.cmd"
        $buildArgs = @("-restore", "-build", "-pack", "-configuration", $Configuration)
        
        Write-Host "Executing: $buildCommand $($buildArgs -join ' ')" @Cyan
        & $buildCommand @buildArgs
        
        if ($LASTEXITCODE -ne 0) {
            throw "Arcade build failed with exit code $LASTEXITCODE"
        }
        
        Write-Success "Arcade build completed successfully"
    }
    finally {
        Set-Location $originalLocation
    }
    
    # Step 3: Create local feed directory
    Write-Section "Setting Up Local Feed"
    
    if (-not (Test-Path $LocalFeedDirectory)) {
        Write-Info "Creating local feed directory: $LocalFeedDirectory"
        New-Item -Path $LocalFeedDirectory -ItemType Directory -Force | Out-Null
        Write-Success "Local feed directory created"
    } else {
        Write-Info "Local feed directory already exists"
        if ($Force) {
            Write-Warning "Clearing existing packages"
            Get-ChildItem $LocalFeedDirectory -Filter "*.nupkg" | Remove-Item -Force
        }
    }
    
    # Step 4: Copy packages
    Write-Section "Copying Packages"
    
    $packagesPath = Join-Path $ArcadeDirectory "artifacts\packages\$Configuration"
    if (-not (Test-Path $packagesPath)) {
        throw "Packages directory not found: $packagesPath"
    }
    
    $packageFiles = Get-ChildItem $packagesPath -Filter "*.nupkg" -Recurse
    Write-Info "Found $($packageFiles.Count) package files"
    
    $copiedCount = 0
    foreach ($package in $packageFiles) {
        $destinationPath = Join-Path $LocalFeedDirectory $package.Name
        if (-not (Test-Path $destinationPath) -or $Force) {
            Copy-Item $package.FullName $destinationPath -Force
            Write-Host "  Copied: $($package.Name)" @Cyan
            $copiedCount++
        } else {
            Write-Host "  Skipped: $($package.Name) (already exists)" @Yellow
        }
    }
    
    Write-Success "Copied $copiedCount package(s) to local feed"
    
    # Step 5: Verify setup
    Write-Section "Verifying Setup"
    
    $finalPackages = Get-ChildItem $LocalFeedDirectory -Filter "*.nupkg"
    Write-Success "Local feed contains $($finalPackages.Count) package(s)"
    
    # Check for key Arcade packages
    $arcadeSdk = $finalPackages | Where-Object { $_.Name -like "Microsoft.DotNet.Arcade.Sdk.*" }
    $installerTasks = $finalPackages | Where-Object { $_.Name -like "Microsoft.DotNet.Build.Tasks.Installers.*" }
    
    if ($arcadeSdk) {
        Write-Success "Found Arcade SDK: $($arcadeSdk.Name)"
    } else {
        Write-Warning "Arcade SDK package not found"
    }
    
    if ($installerTasks) {
        Write-Success "Found Installer Tasks: $($installerTasks.Name)"
    } else {
        Write-Warning "Installer Tasks package not found"
    }
    
    Write-Section "Next Steps"
    Write-Host "1. Your local Arcade WiX v5 packages are ready at:" @Green
    Write-Host "   $LocalFeedDirectory" @Green
    Write-Host "2. Test the WindowsDesktop build:" @Green
    Write-Host "   .\test-wix-v5.ps1 -Action restore" @Green
    Write-Host "3. Build WindowsDesktop with WiX v5:" @Green
    Write-Host "   .\test-wix-v5.ps1 -Action all" @Green
    
}
catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    Write-Host "`nTroubleshooting:" @Yellow
    Write-Host "1. Ensure git is installed and accessible" @Yellow
    Write-Host "2. Check that you have .NET SDK available" @Yellow
    Write-Host "3. Verify network connectivity for git clone" @Yellow
    Write-Host "4. Review build logs for specific errors" @Yellow
    exit 1
}

Write-Success "Arcade WiX v5 local build completed successfully!"
