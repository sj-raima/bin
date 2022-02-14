#!/usr/bin/pwsh

# Print the help text
Function print_help {
    Write-Host "Usage: scd [-Print] [-h|-Help] [--No-Duplicates] [direcory]"
    Write-Host ""
    Write-Host "Change the current working directory based on a leaf, partial, or full"
    Write-Host "directory path such as '14trans' or 'test/rdm-tfs'. If the directory"
    Write-Host "is not unique, the first directory will be used with a warning for"
    Write-Host "other directories."
    Write-Host ""
    Write-Host "Options:"
    Write-Host ""
    Write-Host "    -h|--Help     This help text"
    Write-Host "    --Print       Print out the directory without any warnings instead"
    Write-Host "                  of actually changing the current working directory"
    Write-Host "    --No-Warnings Do not produce any warnings"
    exit 1
}

# We parse the command line
#
# This sets the following Script variables:
#
#    $cd            The command to use when the directory later is found
#    $search_dir    The directory we are searching for ($null or '.' for the top)
#    $no_duplicates Do not warn about duplicates
#
Function parse_cmd_line {
    $Script:cd = 'Set-Location'
    for ($i = 0; $i -lt $Script:args.count; $i++) {
        $arg = $Script:args[$i]
        if ($arg -match '^(-h|-?-[Hh]elp)$') {
            print_help
        }
        elseif ($arg -match '^-?-[Pp]rint$') {
            $Script:cd = 'Write-Host'
            $Script:no_duplicates = $True
        }
        elseif ($arg -match '^-?-[Nn]o-[Ww]arnings?$') {
            $Script:no_duplicates = $True
        }
        elseif ($arg -match '^-') {
            Write-Error "Illegal option: $arg" -ErrorAction stop
        }
        elseif ($search_dir -eq $null) {
            $Script:search_dir = $arg -replace '\\|/', '\\';
        }
        else {
            Write-Error "To many command line arguments ($arg)" -ErrorAction stop
        }
    }
}

Function find_directory {
    $dir = $pwd
    while ($dir -ne "") {
        if ((Test-Path -Path (Join-Path -Path $dir -ChildPath '.git'))) {
            if ($build_dir -eq $Null) {
                $build_dir = $dir
            }
            if ($search_dir -eq $Null -or $search_dir -eq '.') {
                Invoke-Expression "$cd $build_dir"
            }
            else {
                $found = $False
                $ignored_duplicates = $False
                foreach ($rel_path in Get-Content (Join-Path -Path $dir -ChildPath 'dirs')) {
                    if ($rel_path -match "(^|\\)$search_dir$"){
                        $path = Join-Path -Path $build_dir -ChildPath $rel_path
                        if (-Not $found) {
                            $found = $True
                            Invoke-Expression "$cd $path"
                            if ($no_duplicates) {
                                return
                            }
                        }
                        else {
                            if (-Not $ignored_duplicates) {
                                $ignored_duplicates = $True
                                Write-Host 'warning: ignoring these directories'
                            }
                             Write-Host "    $rel_path"
                        }
                    }
                    
                }
                if (-Not $found) {
                    Write-Error "No such directory: $search_dir" -ErrorAction stop
                }
            }
            return
        }
        elseif ((Split-Path $dir -Leaf) -match '^cmake-build-') {
            $build_dir = $dir
        }
        elseif ((Split-Path $dir -Leaf) -match '^b-') {
            $build_dir = $dir
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
