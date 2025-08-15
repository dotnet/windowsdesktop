# WiX v5 Migration Setup

This document describes the setup for using the private Arcade build that includes WiX v5 support.

## Overview

The WindowsDesktop repository has been configured to use a private build of the Arcade SDK from the WiX v5 branch. This allows us to test and validate WiX v5 functionality before it becomes available in the public builds.

## Changes Made

### 1. NuGet.config Updates

The `NuGet.config` file has been updated to include the private Arcade feed:

```xml
<!-- Private Arcade build from WiX v5 branch - PRIORITY: This must be first to override public packages -->
<add key="darc-int-dotnet-arcade-wix-v5" value="https://pkgs.dev.azure.com/dnceng/internal/_packaging/darc-int-dotnet-arcade-wix-v5/nuget/v3/index.json" />
```

**Important**: This feed is listed first to ensure it takes priority over public packages.

### 2. Version Updates

The following files have been updated to use the WiX v5 private build versions:

#### global.json
- `Microsoft.DotNet.Arcade.Sdk`: Updated to `10.0.0-beta.25420.1`
- `Microsoft.DotNet.SharedFramework.Sdk`: Updated to `10.0.0-beta.25420.1`

#### eng/Version.Details.props
- `MicrosoftDotNetArcadeSdkPackageVersion`: Updated to `10.0.0-beta.25420.1`
- `MicrosoftDotNetBuildTasksArchivesPackageVersion`: Updated to `10.0.0-beta.25420.1`
- `MicrosoftDotNetBuildTasksFeedPackageVersion`: Updated to `10.0.0-beta.25420.1`
- `MicrosoftDotNetBuildTasksInstallersPackageVersion`: Updated to `10.0.0-beta.25420.1`
- `MicrosoftDotNetBuildTasksTemplatingPackageVersion`: Updated to `10.0.0-beta.25420.1`
- `MicrosoftDotNetSharedFrameworkSdkPackageVersion`: Updated to `10.0.0-beta.25420.1`

## WiX v5 Features

The private Arcade build includes WiX v5 which provides:

1. **Updated Toolset**: Modern WiX toolchain with improved performance
2. **Enhanced Bundle Support**: Better installer bundle functionality
3. **Improved MSI Generation**: Enhanced MSI creation capabilities
4. **Updated Templates**: Modern installer templates and themes

## Building with WiX v5

### Prerequisites

1. Ensure you have access to the internal Azure DevOps feeds
2. Authenticate with the internal feed using your credentials
3. Clear any local NuGet cache to ensure fresh package downloads

### Building

1. **Restore packages**:
   ```bash
   .\eng\common\build.cmd -restore
   ```

2. **Build installers**:
   ```bash
   .\eng\common\build.cmd -build -pack
   ```

3. **Build bundles**:
   ```bash
   .\eng\common\build.cmd -build -pack -configuration Release
   ```

### Troubleshooting

#### Package Restore Issues

If you encounter package restore issues:

1. Clear the NuGet cache:
   ```bash
   dotnet nuget locals all --clear
   ```

2. Verify feed access:
   ```bash
   dotnet nuget list source
   ```

3. Re-authenticate if necessary:
   ```bash
   dotnet nuget add source "https://pkgs.dev.azure.com/dnceng/internal/_packaging/darc-int-dotnet-arcade-wix-v5/nuget/v3/index.json" --name "darc-int-dotnet-arcade-wix-v5"
   ```

#### Build Failures

If you encounter WiX-related build failures:

1. Check that the WiX toolset is properly restored
2. Verify that the bundle and sfx projects are using the correct SDK versions
3. Check the build logs for specific WiX error messages

## Source References

- **Private Arcade Branch**: https://github.com/PranavSenthilnathan/arcade/tree/wix-v5
- **WiX v5 Documentation**: https://docs.firegiant.com/wix/schema/
- **Arcade Documentation**: https://github.com/dotnet/arcade/blob/master/Documentation/ArcadeSdk.md

## Related Files

The following files are involved in the installer generation:

- `src/windowsdesktop/src/bundle/Microsoft.WindowsDesktop.App.Bundle.bundleproj` - Main bundle project
- `src/windowsdesktop/src/sfx/Microsoft.WindowsDesktop.App.Runtime.sfxproj` - Runtime SFX project
- `src/windowsdesktop/src/sfx/Microsoft.WindowsDesktop.App.Ref.sfxproj` - Reference SFX project
- `src/windowsdesktop/src/bundle/theme/` - WiX localization files (.wxl)
- `src/windowsdesktop/src/bundle/bundle.thm` - Bundle theme file

## Next Steps

1. **Test installer generation** to ensure WiX v5 is working correctly
2. **Validate bundle creation** with the new toolset
3. **Update any custom WiX templates** if needed for v5 compatibility
4. **Monitor for Arcade SDK updates** from the private branch

## Reverting Changes

If you need to revert to the public Arcade build:

1. Remove the private feed from `NuGet.config`
2. Revert version numbers in `global.json` and `eng/Version.Details.props`
3. Clear NuGet cache and restore packages

---

**Note**: This configuration is temporary and intended for testing WiX v5 functionality. Once WiX v5 support is available in the public Arcade builds, these changes should be updated to use the official packages.
