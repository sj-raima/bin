###############################################################################
## PowerShell script to set up the CMake build environment for VS 2019
###############################################################################

if ($ENV:RDM_HOME -eq $null)
{
    $SCRIPT:RDM_HOME = 'C:\Users\dtoyama\rdm\milan'
}
else
{
    $SCRIPT:RDM_HOME = $ENV:RDM_HOME
}

$SCRIPT:S_BUILD_LOCATION='b-vs2019'
$SCRIPT:S_CMAKE_COMPILER='Visual Studio 16 2019'
$SCRIPT:S_ALL_SOURCE='Off'
$SCRIPT:S_DYNAMIC_LIBS='ON'

$SCRIPT:BUILD_PATH = (Join-Path -Path "$SCRIPT:RDM_HOME" -ChildPath "$SCRIPT:S_BUILD_LOCATION")

## Write-Host "$SCRIPT:BUILD_PATH"

if (-Not (Test-Path "$SCRIPT:BUILD_PATH"))
{
    New-Item -ItemType directory -Path "$SCRIPT:BUILD_PATH" | Out-Null
}
Set-Location "$SCRIPT:BUILD_PATH"

$SCRIPT:BUILD_BIN = (Join-Path -Path "$SCRIPT:BUILD_PATH" -ChildPath 'bin')
$SCRIPT:BUILD_LIB = (Join-Path -Path "$SCRIPT:BUILD_PATH" -ChildPath 'lib')

## Start-Process cmake.exe -ArgumentList "-G `"$SCRIPT:S_CMAKE_COMPILER`" .."
cmake.exe -G `""$SCRIPT:S_CMAKE_COMPILER"`" -DBUILD_SHARED_LIBS:BOOL="$SCRIPT:S_DYNAMIC_LIB" -DCOMPILE_ALL_SOURCE:BOOL="$SCRIPT_S_ALL_SOURCE" -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:STRING="$SCRIPT:BUILD_BIN" -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$SCRIPT:BUILD_LIB" ..

