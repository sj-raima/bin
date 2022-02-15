#!/usr/bin/pwsh

# Print the help text
Function print_help {
    Write-Host "Usage: rcd [-Print] [-h|-Help] [direcory]"
    Write-Host
    Write-Host "Change the current working directory based on a build directory name."
    Write-Host "You can omit any prefix starting with 'cmake-build-' or 'b-'."
    Write-Host
    Write-Host "    -h|-Help     This help text"
    Write-Host "    -Print       Print out the directory without any warnings instead"
    Write-Host "                 of actually changing the current working directory" 
    Write-Host "    -No-Warnings Do not produce any warnings"
    exit 1
}

# We parse the command line
#
# This sets the following Script variables:
#
#    $cd        The command to use when the directory later is found
#    $build_dir The build directory ($null or '.' for the source directory)
#
Function parse_cmd_line {
    $Script:cd = 'Set-Location'
    for ($i = 0; $i -lt $Script:args.count; $i++) {
        $arg = $Script:args[$i]
        if ($arg -match '^(-h|-?-[Hh]elp)$') {
            print_help
        }
        elseif ($arg -match '^-?-[Pp]rint$') {
            $Script:cd = 'Write-Output'
        }
        elseif ($arg -match '^-?-[Nn]o-[Ww]arnings?$') {
        }
        elseif ($arg -match '^-') {
            Write-Error "Illegal option: $arg" -ErrorAction stop
        }
        elseif ($build_dir -eq $null) {
            $Script:build_dir = $arg;
        }
        else {
            Write-Error "To many command line arguments ($arg)" -ErrorAction stop
        }
    }
}

# Search the directories
#
# This uses the Script variables set by parse_cmd_line
#
Function find_directory {
    $relpath = '.';
    $dir = $pwd
    while ($dir -ne "") {
        if ((Test-Path -Path (Join-Path -Path $dir -ChildPath '.git'))) {
            foreach ($subdir in ("cmake-build-$build_dir", "b-$build_dir", $build_dir)) {
                $subdirpath = Join-Path -Path $dir -ChildPath $subdir
                if (Test-Path -Path $subdirpath) {
                    $path = Join-Path $subdirpath -ChildPath $relpath
                    if (Test-Path -Path $path -PathType Container) {
                        Invoke-Expression "$cd $path"
                        return
                    }
                    else {
                        Write-Error "Directory $path does not exist" -ErrorAction stop
                    }
                }
            }
            Write-Error "Build directory $build_dir does not exist" -ErrorAction stop
        }
        if ((Split-Path $dir -Leaf) -match '^cmake-build-') {
        }
        elseif ((Split-Path $dir -Leaf) -match '^b-') {
        }
        else {
            $relpath = Join-Path -Path (Split-Path $dir -Leaf) -ChildPath $relpath
        }
        $dir = Split-Path $dir -Parent
    }
    Write-Error "Not inside a project" -ErrorAction stop
}

Try {
    parse_cmd_line
    find_directory
}
Catch {
    Write-Error $_
    exit 1
}
