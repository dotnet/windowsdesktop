# .NET Windows Desktop Runtime

This repo contains the code to build the .NET Windows Desktop Runtime for all
supported platforms.

## Getting started

* [.NET Core 3.1 SDK](https://dotnet.microsoft.com/download/dotnet-core)
* [Windows Forms repository](https://github.com/dotnet/winforms)
* [WPF repository](https://github.com/dotnet/wpf)

## How to Engage, Contribute and Provide Feedback

Some of the best ways to contribute are to try things out, file bugs, join in
design conversations, and fix issues.

* This repo defines [contributing guidelines](CONTRIBUTING.md) and also follows
  the more general [.NET Core contributing
  guide](https://github.com/dotnet/runtime/blob/master/CONTRIBUTING.md).
* If you have a question or have found a bug, [file an
  issue](https://github.com/dotnet/windowsdesktop/issues/new).

### Reporting security issues and security bugs

Security issues and bugs should be reported privately, via email, to the
Microsoft Security Response Center (MSRC) <secure@microsoft.com>. You should
receive a response within 24 hours. If for some reason you do not, please follow
up via email to ensure we received your original message. Further information,
including the MSRC PGP key, can be found in the [Security
TechCenter](https://www.microsoft.com/msrc/faqs-report-an-issue).

Also see info about related [Microsoft .NET Core and ASP.NET Core Bug Bounty
Program](https://www.microsoft.com/msrc/bounty-dot-net-core).

### .NET Framework issues

Issues with .NET Framework should be filed on [VS developer
community](https://developercommunity.visualstudio.com/spaces/61/index.html), or
[Product Support](https://support.microsoft.com/en-us/contactus?ws=support).
They should not be filed on this repo.

## Code of Conduct

This project uses the [.NET Foundation Code of
Conduct](https://dotnetfoundation.org/code-of-conduct) to define expected
conduct in our community. Instances of abusive, harassing, or otherwise
unacceptable behavior may be reported by contacting a project maintainer at
conduct@dotnetfoundation.org.

## License

.NET Core (including the WindowsDesktop repo) is licensed under the [MIT license](LICENSE.TXT).

## Officially Released Builds

Download official .NET releases [here](https://www.microsoft.com/net/download#core).

## Daily Builds

<!--
  To update this table, run 'build.sh/cmd /p:Subset=RegenerateReadmeTable'. See
  'tools-local/regenerate-readme-table.proj' to add or remove rows or columns,
  and add links below to fill out the table's contents.
-->
<!-- BEGIN generated table -->

| Platform | Master |
| --- |  :---: |
| **Windows (x64)** | [![][win-x64-badge-master]][win-x64-version-master]<br>[Installer][win-x64-installer-master] ([Checksum][win-x64-installer-checksum-master])<br>[zip][win-x64-zip-master] ([Checksum][win-x64-zip-checksum-master]) |
| **Windows (x86)** | [![][win-x86-badge-master]][win-x86-version-master]<br>[Installer][win-x86-installer-master] ([Checksum][win-x86-installer-checksum-master])<br>[zip][win-x86-zip-master] ([Checksum][win-x86-zip-checksum-master]) |

<!-- END generated table -->

<!-- BEGIN links to include in table -->

[win-x64-badge-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/sharedfx_win-x64_Release_version_badge.svg
[win-x64-version-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/latest.version
[win-x64-installer-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x64.exe
[win-x64-installer-checksum-master]: https://dotnetclichecksums.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x64.exe.sha512
[win-x64-zip-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x64.zip
[win-x64-zip-checksum-master]: https://dotnetclichecksums.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x64.zip.sha512


[win-x86-badge-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/sharedfx_win-x86_Release_version_badge.svg
[win-x86-version-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/latest.version
[win-x86-installer-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x86.exe
[win-x86-installer-checksum-master]: https://dotnetclichecksums.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x86.exe.sha512
[win-x86-zip-master]: https://dotnetcli.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x86.zip
[win-x86-zip-checksum-master]: https://dotnetclichecksums.blob.core.windows.net/dotnet/WindowsDesktop/master/windowsdesktop-runtime-latest-win-x86.zip.sha512

<!-- END links to include in table -->
