#!/usr/bin/env pwsh
#
# Setup script for WiX v5 private feed authentication
# This script helps configure authentication for the private Arcade feed
#

param(
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowDetails
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

Write-Host "WindowsDesktop WiX v5 Feed Setup" @Cyan
Write-Host "=================================" @Cyan

# Check if we're in the right directory
if (-not (Test-Path "NuGet.config")) {
    Write-Error "NuGet.config not found. Please run this script from the repository root."
    exit 1
}

# Check current NuGet sources
Write-Info "Checking current NuGet sources..."
try {
    $sources = dotnet nuget list source
    if ($ShowDetails) {
        Write-Host "Current sources:" @Cyan
        Write-Host $sources
    }
}
catch {
    Write-Warning "Failed to list NuGet sources: $($_.Exception.Message)"
}

# Verify the local feed is configured
$nugetConfig = Get-Content "NuGet.config" -Raw
if ($nugetConfig -match "local-arcade-wix-v5") {
    Write-Success "Local Arcade WiX v5 feed is configured in NuGet.config"
    
    # Check if local directory exists
    $localFeedPath = "C:\local-packages\arcade-wix-v5"
    if (Test-Path $localFeedPath) {
        $packages = Get-ChildItem $localFeedPath -Filter "*.nupkg"
        Write-Success "Local feed directory exists with $($packages.Count) package(s)"
        if ($ShowDetails -and $packages.Count -gt 0) {
            Write-Host "Packages found:" @Cyan
            $packages | ForEach-Object { Write-Host "  - $($_.Name)" @Cyan }
        }
    } else {
        Write-Warning "Local feed directory does not exist: $localFeedPath"
        Write-Info "You need to build Arcade locally first - see BUILD-ARCADE-LOCALLY.md"
    }
} else {
    Write-Error "Local Arcade WiX v5 feed is not configured in NuGet.config"
    Write-Info "Please configure local feed path - see BUILD-ARCADE-LOCALLY.md"
    exit 1
}

# Check if we have .NET SDK available for building
Write-Info "Checking Azure CLI availability..."
try {
    $azVersion = az --version 2>$null
    if ($azVersion) {
        Write-Success "Azure CLI is available"
        
        # Check if logged in
        try {
            $azAccount = az account show 2>$null | ConvertFrom-Json
            if ($azAccount) {
                Write-Success "Logged in to Azure as: $($azAccount.user.name)"
            }
        }
        catch {
            Write-Warning "Not logged in to Azure CLI"
            Write-Info "Run 'az login' to authenticate"
        }
    }
}
catch {
    Write-Warning "Azure CLI not found or not available"
    Write-Info "Consider installing Azure CLI for easier authentication"
}

# Check if dotnet credential provider is available
Write-Info "Checking .NET credential provider..."
$credProviderPath = "$env:USERPROFILE\.nuget\plugins\netcore\CredentialProvider.Microsoft"
if (Test-Path $credProviderPath) {
    Write-Success ".NET credential provider is installed"
} else {
    Write-Warning ".NET credential provider not found"
    Write-Info "The credential provider may be installed automatically during restore"
}

# Provide guidance
Write-Host "`nNext Steps:" @Cyan
Write-Host "1. Clone and build Arcade WiX v5 branch locally" @Cyan
Write-Host "2. Copy built packages to C:\local-packages\arcade-wix-v5" @Cyan
Write-Host "3. Run './test-wix-v5.ps1 -Action restore' to test package restore" @Cyan
Write-Host "4. See BUILD-ARCADE-LOCALLY.md for detailed build instructions" @Cyan

Write-Host "`nLocal Build Process:" @Yellow
Write-Host "• git clone https://github.com/PranavSenthilnathan/arcade.git -b wix-v5" @Yellow
Write-Host "• cd arcade && .\\eng\\common\\build.cmd -restore -build -pack" @Yellow
Write-Host "• Copy artifacts\\packages\\**\\*.nupkg to C:\\local-packages\\arcade-wix-v5\\" @Yellow

Write-Success "Feed setup validation completed"
