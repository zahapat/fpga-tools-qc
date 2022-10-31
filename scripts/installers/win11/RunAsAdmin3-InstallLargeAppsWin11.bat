@REM Visual Studio 2022 Community
@REM CLI parameters can be found at:
@REM     https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022
@REM VS Components can be found at:
@REM     https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?view=vs-2022&preserve-view=true
@REM This installation includes: Desktop development with C++:
@REM     Microsoft.VisualStudio.Workload.NativeDesktop
@REM winget install --id=Microsoft.VisualStudio.2022.Community  -e
winget install --id Microsoft.VisualStudio.2022.Community  -e --override "--add Microsoft.VisualStudio.Workload.NativeDesktop"
pause