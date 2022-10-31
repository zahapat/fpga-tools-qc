setx VCPKG_DEFAULT_TRIPLET x64-windows /m
cd C:\
mkdir dev
cd dev
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
start cmd /k ".\bootstrap-vcpkg.bat && .\vcpkg integrate install && pause && exit"
pause
@REM CMake projects should use: "-DCMAKE_TOOLCHAIN_FILE=C:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake"
@REM All MSBuild C++ projects can now #include any installed libraries. Linking will be handled automatically. Installing new libraries will make them instantly available.