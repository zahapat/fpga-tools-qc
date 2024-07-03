cmake_minimum_required(VERSION 3.24.0)

# set(CMAKE_CXX_STANDARD 20)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
# set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_TOOLCHAIN_FILE "C:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake")

set( CMAKE_C_COMPILER "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.34.31933/bin/Hostx64/x64/cl.exe" )
set( CMAKE_CXX_COMPILER "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.34.31933/bin/Hostx64/x64/cl.exe" )
# C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.34.31933/bin/Hostx64/x64/cl.exe
# C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.34.31933/bin/Hostx64/x64/cl.exe

project(redis)

set(
    SRCS 
    "main.cpp"
)


# CMake found path to <LIBNAME>-config.cmake
# set(BOOST_ROOT C:/dev/vcpkg/installed/x64-windows/include)
# find_package(Boost)
# set(Boost_USE_STATIC_LIBS        ON)  # only find static libs
# set(Boost_USE_DEBUG_LIBS         OFF) # ignore debug libs and 
# set(Boost_USE_RELEASE_LIBS       ON)  # only find release libs 
# set(Boost_USE_MULTITHREADED      ON)
# set(Boost_USE_STATIC_RUNTIME     OFF)


# CMake found path to __LIBNAME__-config.cmake
# find_package(fmt CONFIG REQUIRED)
find_package(hiredis CONFIG REQUIRED)


# CMake did not find the path to __LIBNAME__-config.cmake
# set(redis++_DIR C:/dev/vcpkg/packages/redis-plus-plus_x64-windows/share/cmake/redis++)
find_package(redis++ CONFIG REQUIRED)

# CMake did not find the path to __LIBNAME__-config.cmake
# set(okFrontPanel_DIR C:/Users/Patrik/gflow/gflow_ok_clean/py/gui/redis/)
# find_package(okFrontPanel CONFIG REQUIRED)

# VS did not find the path to okFrontPanel libraries:
# link_directories(C:/Users/Patrik/gflow/gflow_ok_clean/py/gui/redis/lib)
link_directories(lib)


add_executable(
    ${PROJECT_NAME}
    ${SRCS}
)

target_link_libraries(
    ${PROJECT_NAME}
    hiredis::hiredis
    redis++::redis++
    okFrontPanel.lib
    okFrontPanel.dll
)

# if()
    # include_directories(${Boost_INCLUDE_DIRS})

#     add_executable(
#         ${PROJECT_NAME}
#         ${SRCS}
#     )

#     target_link_libraries(
#         ${PROJECT_NAME}
#         hiredis::hiredis
#         redis++::redis++
#         okFrontPanel.lib
#         okFrontPanel.dll
#     )
# endif()
