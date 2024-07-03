cmake_minimum_required(VERSION 3.24.0)

set(CMAKE_TOOLCHAIN_FILE "C:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake")

set( CMAKE_C_COMPILER "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.34.31933/bin/Hostx64/x64/cl.exe" )
set( CMAKE_CXX_COMPILER "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.34.31933/bin/Hostx64/x64/cl.exe" )

project(csv_readout)

set(
    SRCS 
    "main.cpp"
)

# VS did not find the path to okFrontPanel libraries:
link_directories(lib)

add_executable(
    ${PROJECT_NAME}
    ${SRCS}
)

target_link_libraries(
    ${PROJECT_NAME}
    okFrontPanel.lib
    okFrontPanel.dll
)