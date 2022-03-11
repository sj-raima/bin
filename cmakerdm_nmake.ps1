###############################################################################
## PowerShell script to set up the CMake build environment for NMake (64-bit)
###############################################################################
param
(
    [string]$branch = 'milan',
    [switch]$shared = $false
)

# Determine the target arch of the compiler
$SCRIPT:cl_string = &"cl.exe" 2>&1
$SCRIPT:cl_arch = ($cl_string -split 'for ')[1]

if ($cl_arch -eq 'x64')
{
    $SCRIPT:arch = '64'
}
elseif ($cl_arch -eq 'x86')
{
    $SCRIPT:arch = '32'
}
else
{
    Write-Error 'Unsupported architecture'
    exit 1
}

if ($shared)
{
    $SCRIPT:ext = '-dll'
}
else
{
    $SCRIPT:ext = ''
}

$SCRIPT:RDM_HOME = "C:\Users\dtoyama\rdm\$branch"

$SCRIPT:S_BUILD_LOCATION = "b-nmake-$arch$ext"
$SCRIPT:S_CMAKE_COMPILER = 'NMake Makefiles'
$SCRIPT:S_ALL_SOURCE='Off'

$SCRIPT:BUILD_PATH = (Join-Path -Path "$SCRIPT:RDM_HOME" -ChildPath "$SCRIPT:S_BUILD_LOCATION")

## Write-Host "$SCRIPT:BUILD_PATH"

if (-Not (Test-Path "$SCRIPT:BUILD_PATH"))
{
    New-Item -ItemType directory -Path "$SCRIPT:BUILD_PATH" | Out-Null
}
Set-Location "$SCRIPT:BUILD_PATH"

if ($SCRIPT:ext -eq '-dll')
{
    $SCRIPT:BUILD_BIN = (Join-Path -Path "$SCRIPT:BUILD_PATH" -ChildPath 'bin')
    $SCRIPT:BUILD_LIB = (Join-Path -Path "$SCRIPT:BUILD_PATH" -ChildPath 'lib')

    cmake.exe -G `""$SCRIPT:S_CMAKE_COMPILER"`" -DBUILD_SHARED_LIBS:BOOL=ON -DCOMPILE_ALL_SOURCE:BOOL="$SCRIPT:S_ALL_SOURCE" -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:STRING="$SCRIPT:BUILD_BIN" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$SCRIPT:BUILD_LIB" ..
}
else
{
    cmake.exe -G `""$SCRIPT:S_CMAKE_COMPILER"`" -DCOMPILE_ALL_SOURCE:BOOL="$SCRIPT:S_ALL_SOURCE" ..
}

