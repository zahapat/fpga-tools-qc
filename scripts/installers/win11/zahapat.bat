@REM Make a new dir if does not exist in user root dir
cd C:\
mkdir Git
cd Git
RMDIR /S /Q %~n0

@REM Clone All Repositories From User: zahapat
powershell -command "gh auth login"
start "" "%PROGRAMFILES%\Git\git-bash.exe" ^
    -c "gh repo list %~n0 --limit 1000 | while read -r repo _; do gh repo clone "$repo" "$repo"; done; read -s -n 1 -p 'Press any key to continue...'"