if exist gui.exe (
    rem file gui.exe exists
    rm gui.exe
)
pyinstaller.exe --onefile --noconsole guiLauncher.py
rm -r build/*
rmdir build
mv dist/guiLauncher.exe ./gui.exe
rmdir dist
rm guiLauncher.spec