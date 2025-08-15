# Building Arcade WiX v5 Locally

Since the WiX v5 Arcade branch is a draft PR without published packages, you need to build it locally and create a local package feed.

## Step 1: Clone and Build Arcade

```bash
# Clone the WiX v5 branch
git clone https://github.com/PranavSenthilnathan/arcade.git -b wix-v5 C:\arcade-wix-v5

# Navigate to Arcade directory
cd C:\arcade-wix-v5

# Build and pack Arcade with WiX v5
.\eng\common\build.cmd -restore -build -pack -configuration Release

# Or build specific projects if needed
.\eng\common\build.cmd -restore -build -pack -projects src\Microsoft.DotNet.Arcade.Sdk\Microsoft.DotNet.Arcade.Sdk.csproj -configuration Release
```

## Step 2: Create Local Package Feed

```bash
# Create a local feed directory
mkdir C:\local-packages\arcade-wix-v5

# Copy packages to local feed
copy "C:\arcade-wix-v5\artifacts\packages\Release\Shipping\*.nupkg" "C:\local-packages\arcade-wix-v5\"
copy "C:\arcade-wix-v5\artifacts\packages\Release\NonShipping\*.nupkg" "C:\local-packages\arcade-wix-v5\"
```

## Step 3: Update NuGet.config in WindowsDesktop

Replace the Azure DevOps feed with your local feed:

```xml
<packageSources>
  <!-- Local WiX v5 Arcade feed - HIGHEST PRIORITY -->
  <add key="local-arcade-wix-v5" value="C:\local-packages\arcade-wix-v5" />
  
  <!-- Keep other feeds -->
  <add key="dotnet-public" value="https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-public/nuget/v3/index.json" />
  <!-- ... other feeds ... -->
</packageSources>
```

## Step 4: Update Version Numbers

Make sure the versions in your WindowsDesktop repo match what was actually built:

1. Check what version was built in Arcade:
```bash
cd C:\arcade-wix-v5
dir artifacts\packages\Release\Shipping\Microsoft.DotNet.Arcade.Sdk.*.nupkg
```

2. Update `global.json` and `eng\Version.Details.props` to match the exact version.

## Step 5: Test the Build

```bash
cd C:\Users\mmcgaw\Repos\windowsdesktop
.\test-wix-v5.ps1 -Action restore
```

## Alternative: Use Darc for Local Build

If you have `darc` tool available:

```bash
# In the arcade directory
darc get-dependency-graph --local

# Build with version information
.\eng\common\build.cmd -restore -build -pack -ci
```

## Troubleshooting

1. **Package Version Mismatch**: The version numbers in your config must exactly match the built packages
2. **Build Order**: Build Arcade first, then update WindowsDesktop configuration
3. **Clear Caches**: Run `.\test-wix-v5.ps1 -CleanFirst` to clear any cached packages

## Example Workflow

```bash
# 1. Build Arcade WiX v5
cd C:\arcade-wix-v5
.\eng\common\build.cmd -restore -build -pack -configuration Release

# 2. Check what version was built
dir artifacts\packages\Release\Shipping\Microsoft.DotNet.Arcade.Sdk.*.nupkg

# 3. Copy packages to local feed
robocopy "artifacts\packages\Release\Shipping" "C:\local-packages\arcade-wix-v5" *.nupkg
robocopy "artifacts\packages\Release\NonShipping" "C:\local-packages\arcade-wix-v5" *.nupkg

# 4. Update WindowsDesktop configuration with exact version numbers

# 5. Test WindowsDesktop build
cd C:\Users\mmcgaw\Repos\windowsdesktop
.\test-wix-v5.ps1 -Action all -CleanFirst
```
