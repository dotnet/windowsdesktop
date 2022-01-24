APICompat is only for servicing releases (PreReleaseVersionLabel=servicing && PatchVersion>0) between the serviced ref-pack and GA's ref pack to protect us from accidentally exposing new API in servicing.

## How it all hangs together

During the build we download the following GA ref packs (i.e., targeting 6.0.0, 7.0.0, etc.):
* Microsoft.NETCore.App.Ref
* Microsoft.WindowsDesktop.App.Ref
* Microsoft.NETCore.App.Runtime.win-x64

After that we resolve ref assemblies that form Windows Desktop SDK (those part of `FrameworkListFileClass` collection) and are shipped in the Windows Forms and WPF transport packages (i.e., Microsoft.Private.Winforms and Microsoft.DotNet.Wpf.GitHub respectvely).

Then we compose APICompat tool command line args and write those into `apicompat.winforms.rsp` and `apicompat.wpf.rsp`, and run the tool for the Windows Forms ref assemblies and then for the WPF ref assemblies, e.g.:
```
dotnet.exe .\.packages\microsoft.dotnet.apicompat\6.0.0-beta.21609.4\tools\netcoreapp3.1\Microsoft.DotNet.ApiCompat.dll @".\artifacts\obj\Microsoft.WindowsDesktop.App.Ref\Release\net6.0\win-x64\apicompat.winforms.rsp"
```

If there are any API discrepancies - the build will fail.

## For new servicing release

For the first servicing release the build will fail with the following error:

> _Windows Forms API compat baseline for net6.0 must be created and stored in '.\eng\ApiCompat\baseline.net6.0.winforms.txt'_

To create a new baseline (and confirm it is expected) run a build with the following argument:

```
.\build.cmd -c Release /p:CreateBaseline=true
```