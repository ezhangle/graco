:: .............................................................................
::
::  This file is part of the AXL library.
::
::  AXL is distributed under the MIT license.
::  For details see accompanying license.txt file,
::  the public copy of which is also available at:
::  http://tibbo.com/downloads/archive/axl/license.txt
::
:: .............................................................................

@echo off

:loop

if "%1" == "" goto :finalize
if /i "%1" == "msvc10" goto :msvc10
if /i "%1" == "msvc12" goto :msvc12
if /i "%1" == "msvc14" goto :msvc14
if /i "%1" == "x86" goto :x86
if /i "%1" == "i386" goto :x86
if /i "%1" == "amd64" goto :amd64
if /i "%1" == "x86_64" goto :amd64
if /i "%1" == "x64" goto :amd64

echo Invalid argument: '%1'
exit -1

:: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

:: Toolchain

:msvc10
set TOOLCHAIN=msvc10
set CMAKE_GENERATOR=Visual Studio 10 2010
set LUA_TOOLCHAIN=vc10
shift
goto :loop

:msvc12
set TOOLCHAIN=msvc12
set CMAKE_GENERATOR=Visual Studio 12 2013
set LUA_TOOLCHAIN=vc12
shift
goto :loop

:msvc14
set TOOLCHAIN=msvc14
set CMAKE_GENERATOR=Visual Studio 14 2015
set LUA_TOOLCHAIN=vc14
shift
goto :loop

:: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

:: Platform

:x86
set TARGET_CPU=x86
set CMAKE_GENERATOR_SUFFIX=
set LUA_PLATFORM=Win32
shift
goto :loop

:amd64
set TARGET_CPU=amd64
set CMAKE_GENERATOR_SUFFIX= Win64
set LUA_PLATFORM=Win64
shift
goto :loop

:: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

:finalize

if "%TOOLCHAIN%" == "" goto :msvc14
if "%TARGET_CPU%" == "" goto :amd64
if "%CONFIGURATION%" == "" (set CONFIGURATION=Release)

set LUA_VERSION=5.3.3
set LUA_LIB_NAME=lua53
set LUA_DOWNLOAD_FILE=lua-%LUA_VERSION%_%LUA_PLATFORM%_%LUA_TOOLCHAIN%_lib.zip
set LUA_DOWNLOAD_URL=https://sourceforge.net/projects/luabinaries/files/%LUA_VERSION%/Windows%%20Libraries/Static/%LUA_DOWNLOAD_FILE%/download

set RAGEL_DOWNLOAD_FILE=ragel-68-visualstudio2012.7z
set RAGEL_DOWNLOAD_URL=http://downloads.yorickpeterse.com/files/%RAGEL_DOWNLOAD_FILE%

set CMAKE_FLAGS=-G "%CMAKE_GENERATOR%%CMAKE_GENERATOR_SUFFIX%" -DTARGET_CPU=%TARGET_CPU%

set MSBUILD_FLAGS=/nologo /verbosity:minimal /consoleloggerparameters:Summary /maxcpucount /property:configuration=%CONFIGURATION%

echo ---------------------------------------------------------------------------
echo LUA_LIB_NAME:       %LUA_LIB_NAME%
echo LUA_DOWNLOAD_URL:   %LUA_DOWNLOAD_URL%
echo RAGEL_DOWNLOAD_URL: %RAGEL_DOWNLOAD_URL%
echo CMAKE_FLAGS:        %CMAKE_FLAGS%
echo MSBUILD_FLAGS:      %MSBUILD_FLAGS%
echo ---------------------------------------------------------------------------
