# Copilot Instructions

## Project Context

This project is to migrate the existing WindowsDesktop Shared Framework bundle from WiXv3 to WiXv5 using all of the patterns and practices that are appropriate for .NET products

## Reference Pull Requests

These PRs demonstrate the coding patterns, architecture decisions, and implementation approach you should follow:

### Primary Reference PRs
- **PR #48699**: .NET SDK PR - [\[Link to PR\]](https://github.com/dotnet/sdk/pull/48699)
  - Make sure we follow all patterns set in place.
  - Upgrade and detection patterns are key to follow
  
- **PR #117010**: .NET Runtime SDK - [\[Link to PR\]](https://github.com/dotnet/runtime/pull/117010/)
  - Simpler than what we do. We need to chain the runtime components and then add our WindowsDesktop MSI to our bundle.
  - We do need to follow the detection and upgrade patterns set here. This is critical for our ability to upgrade and detect installs.

### Secondary Reference PRs
- **PR #62885**: ASP.NET Core - [\[Link to PR\]](https://github.com/dotnet/aspnetcore/pull/62885/)
  - Specific technique: This PR is more complex than the WindowsDesktop PR as it has to worry about IIS, so ignore anything specific to web tech
  - Also note there's a lot in here that may be non-Windows. Ignore that.
  - This PR does detect and chain the required runtime components that are a prerequisite for both WindowsDesktop and ASP.NET Core. Follow those patterns

## Coding Rules and Standards

### Must Follow
1. Follow all standard Arcade patterns
2. Calculate GUIDs with seeds where possible
3. New installer must be able to in-place-update from previous preview releases of .NET 10
4. New installer must be able to in-place-update during servicing. This must follow the same pattern as the reference PRs
5. New installer must be able to install SxS with any other major version of .NET. This also must follow the pattern of reference PRs.
6. Keep changes minimal and comments crisp.
1. Try to use central package management where we can.

### Never Do
1. Hard code GUIDs if not done so in other PRs
1.Extraneous changes not part of the migration to WiXv5

## Implementation Guidelines

### Before Starting Work
1. Review the reference PRs listed above
2. Understand the existing codebase patterns
3. Plan the implementation approach
4. Consider backward compatibility

### During Implementation
1. Follow the established patterns from reference PRs
2. Maintain consistency with existing code
3. Add appropriate tests following the patterns shown
4. Update documentation as needed

### Before Submitting
1. Verify code follows all established patterns
2. Ensure tests pass and coverage is maintained
3. Update relevant documentation
4. Self-review against reference PR standards

## Project-Specific Context

### Key Technologies
- WiX v5
- Arcade (.NET infrastructure provider)
-.NET Core, WinForms, WPF

## Additional Notes
We are using a custom built version of WiXv5 specific to the .NET ecosystem.  
---

**Remember**: When in doubt, refer back to the reference PRs and follow their patterns. Consistency is key to maintainable code.