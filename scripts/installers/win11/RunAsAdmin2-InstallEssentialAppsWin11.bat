powershell (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
wsl --install
wsl --update --inbox
wsl --update --web-download
wsl --install -d ubuntu
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco -?
choco upgrade chocolatey
choco install -yes python
python --version
pip --version
winget install --id Microsoft.Powershell --source winget
winget install --id Git.Git -e --source winget
winget install -e --id Kitware.CMake
choco install make
choco install -yes gh
powershell -command "winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'"
pause