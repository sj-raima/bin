###############################################################################
## PowerShell script to set up the CMake build environment for NMake (64-bit)
###############################################################################

if ($args.count -eq 0)
{
    $SCRIPT:BRANCH = 'milan'
}
elseif ($args.count -eq 1)
{
    $SCRIPT:BRANCH = $args[0]
}
else
{
    $Host.UI.WriteErrorLine("CMAKERDM only takes one argument")
    exit 1
}

$SCRIPT:RDM_HOME = "C:\Users\dtoyama\rdm\$SCRIPT:BRANCH"

$SCRIPT:S_BUILD_LOCATION='b-nmake-64'
$SCRIPT:S_CMAKE_COMPILER='NMake Makefiles'
$SCRIPT:S_ALL_SOURCE='Off'

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
cmake.exe -G `""$SCRIPT:S_CMAKE_COMPILER"`" -DCOMPILE_ALL_SOURCE:BOOL="$SCRIPT:S_ALL_SOURCE" ..

