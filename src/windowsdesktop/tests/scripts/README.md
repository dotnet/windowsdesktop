# Runtime Prerequisite Helper Scripts

This directory contains helper scripts used to stage (or simulate) the .NET runtime MSIs that may be bundled into the WindowsDesktop WiX v5 installer.

## Scripts

### acquire-runtime-msis.ps1

Acquires real runtime MSIs (host, hostfxr, runtime) from either a build artifact drop folder or an expanded runtime build ZIP, then normalizes them into the deterministic staging contract:

```text
artifacts/prereqs/<arch>/
  dotnet-host-win-<arch>.msi
  dotnet-hostfxr-win-<arch>.msi
  dotnet-runtime-win-<arch>.msi
  resolved-runtime-version.txt
```

Parameters:

- `-Architecture <x64|x86|arm64>` (required)
- `-Destination <path>` optional (defaults to `artifacts/prereqs/<arch>`)
- `-SourceDrop <path>` path containing *un-renamed* runtime MSIs (copies the latest version of each)
- `-RuntimeBuildZip <path>` zip produced by a runtime build that contains the MSIs; expanded and processed

Exactly one of `-SourceDrop` or `-RuntimeBuildZip` must be provided.

Outputs:

- Normalized MSI triad copied/renamed as above
- `resolved-runtime-version.txt` containing a single line `RuntimePrereqVersion=<original-runtime-msi-basename>` (informational)

Failure conditions:

- Missing or unreadable input (exit 1/2/3)
- Fewer than all three MSIs discoverable (exit 4)

### make-dummy-runtime-msis.ps1

Creates placeholder files (NOT valid MSIs) for local structural testing of the bundle build logic (e.g., verifying `IncludeRuntimeMSIs` gating). These placeholders allow the build to proceed through most WiX phases, but any step that requires actual MSI metadata will fail.

Parameters:

- `-Architecture <x64|x86|arm64>` (required)
- `-Destination <path>` optional (defaults to `artifacts/prereqs/<arch>`)
- `-Version <string>` optional, default `0.0.0-dummy` (recorded in `resolved-runtime-version.txt`)

Outputs:

- Three small text files named like real MSIs
- `resolved-runtime-version.txt` capturing the dummy version

Caveats:

- Do NOT publish or distribute bundles built with dummy files.
- Use only to verify conditional logic / build orchestration.

## Build Integration

The WiX project (`bundle.wixproj`) uses a deterministic staging contract. If (and only if) the three normalized MSI files are present in `artifacts/prereqs/<arch>` when `StagePrereqRuntimeMsis` runs, the bundle defines `IncludeRuntimeMSIs=true` and embeds them; otherwise it proceeds without them.

Internal CI: missing or partial triad triggers a build warning or error per policy.
Public PR builds: typically do not supply real MSIs; the bundle is produced without runtime prereqs unless explicitly staged.

## Typical Workflows

1. Acquire real runtime MSIs from an extracted runtime build:

```powershell
pwsh src/windowsdesktop/tests/scripts/acquire-runtime-msis.ps1 -Architecture x64 -SourceDrop C:/path/to/runtime/msis
```

1. Acquire from a runtime build zip:

```powershell
pwsh src/windowsdesktop/tests/scripts/acquire-runtime-msis.ps1 -Architecture arm64 -RuntimeBuildZip C:/drops/runtime-msis.zip
```

1. Generate dummy placeholders (structural test only):

```powershell
pwsh src/windowsdesktop/tests/scripts/make-dummy-runtime-msis.ps1 -Architecture x86 -Version 9.0.0-dummy
```

1. Build the bundle after staging:

```powershell
./build.cmd -configuration Release -architecture x64
```

## Troubleshooting

- If the bundle still excludes runtime MSIs, ensure all three normalized file names match exactly and are in the architecture-specific directory.
- Delete stale prereqs: `Remove-Item -Recurse -Force artifacts/prereqs` then re-run acquisition.
- Verify runtime version captured: `Get-Content artifacts/prereqs/x64/resolved-runtime-version.txt`.

## Future Enhancements (Ideas)

- Optional hash verification to ensure MSIs are authentic.
- Multi-architecture acquisition loop.
- Integration test that asserts gating behavior with/without the triad.

---
Maintainers: adjust this doc if the staging contract or target names change.
