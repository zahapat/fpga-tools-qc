@REM Make a new dir if does not exist in user root dir
cd %userprofile%
cd
mkdir Git
cd Git

@REM Clone All Repositories One by One: user=zahapat
@REM gh repo list myorgname --limit 1000 | while read -r repo _; do
@REM   gh repo clone "$repo" "$repo"
@REM done

SETLOCAL EnableDelayedExpansion
@REM powershell -command "gh auth login"

start "" "%PROGRAMFILES%\Git\git-bash.exe" ^
    -c "gh repo list zahapat --limit 1000 | while read -r repo _; do gh repo clone "$repo" "$repo"; done; read -s -n 1 -p 'Press any key to continue...'"
    @REM -c "{ echo "Hello";}; read -s -n 1 -p 'Press any key to continue...'"
    @REM -c "for i in 1 2 3; { echo "$i";}; read -s -n 1 -p 'Press any key to continue...'"

@REM for i in 1 2 3
@REM do
@REM   echo "$i"
@REM done

    @REM gh repo list zahapat --limit 1000 | while read -r repo _; !="!^
    @REM do gh repo clone '$repo' '$repo' done; !="!^
    @REM read -s -n 1 -p 'Press any key to continue...'"
       
       
@REM -c "pwd; read -s -n 1 -p 'Press any key to continue...'; gh repo list myorgname --limit 1000 | while read -r repo _; do gh repo clone "$repo" "$repo" done; read -s -n 1 -p 'Press any key to continue...'"
@REM pause