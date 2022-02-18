#!/usr/bin/pwsh

# Print the help text
Function print_help {
    Write-Host "Usage: rdm [-Make] [-Link] [-release] [-Debug] [-h|-Help] <command> <arguments>"
    Write-Host
    Write-Host "Run an RDM command line tool. Search for the tool in the following order;"
    Write-Host "source/rdm-<command, bin, bin/Debug, and bin/Release"
    Write-Host
    Write-Host "    -h|-Help    Print this help"
    Write-Host "    -Make       Build the tool before executing it"
    Write-Host "    -Link       Make a symbolic link for the command to the current"
    Write-Host "                working directory"
    Write-Host "    -Debug      Use bin/Debug before any of the other bin directories"
    Write-Host "    -Release    Use bin/Release before any of the other bin directories"
    Write-Host "    <command>   The rdm-<command> to execute"
    Write-Host "    <arguments> Arguments that are to be passed on to rdm-<command>"
    Write-Host
    exit 1
}

# Shift the scripts args similar to Bourne Shell shift
function shift {
    $Null, $Script:args = $Script:args
}

# We parse the command line
#
# This sets the following Script variables:
#
#    $make        Set if the command should be made using make or nmake
#    $link        Should we make a link for the command
#    $bin_dir     The bin directory to seach first
#
Function parse_cmd_line {
    $Script:bin_dir = 'bin'
    while ($Script:args.count -gt 0) {
        $arg = $Script:args[0]
        if ($arg -match '^(-h|-?-[Hh]elp)$') {
            print_help
        }
        elseif ($arg -match '^-?-[Mm]ake$') {
            if ($IsLinux -or $IsMacOS) {
                $Script:make = "make"
            }
            else {
                $Script:make = "nmake"
            }
            shift
        }
        elseif ($arg -match '^-?-[Ll]ink$') {
            $Script:link = $True
            shift
        }
        elseif ($arg -match '^-?-[Rr]elease$') {
            $Script:bin_dir = 'bin/Release'
            shift
        }
        elseif ($arg -match '^-?-[Dd]ebug$') {
            $Script:bin_dir = 'bin/Debug'
            shift
        }
        elseif ($arg -match '^-') {
            Write-Error "Illegal option: $arg" -ErrorAction stop
        }
        elseif ($build_dir -eq $null) {
            $Script:command = $arg;
            shift
            return
        }
    }

    Write-Error "Command is missing" -ErrorAction stop
}

Function run_make {
    if ($Script:make -ne $Null) {
        $orig_dir = $pwd
        try {
            scd -No-Warnings "rdm-$command" 2>$null
            if (-Not $?) {
                Write-Error "Failed to find command rdm-$command" -ErrorAction stop
            }
            $null = (& $make 2> $null)
            if (-Not $?) {
                Write-Error "Running make failed" -ErrorAction stop
            }
        }
        finally {
            cd $orig_dir
        }
    }
}

Function make_link {
    if ($Script:link) {
        $dir = (scd -Print "rdm-$command") 2>$null
        if (-Not $?) {
            Write-Error "Failed to find command rdm-$command" -ErrorAction stop
        }
        ln -s (Join-Path -Path $dir -ChildPath "rdm-$command") "rdm-$command"
        exit 0
    }
}

Function run_command {
    foreach ($dir in (scd -Print "rdm-$command" 2>$null),
                     (join-Path -Path (scd -Print . 2>$null) -ChildPath "$Script:bin_dir"),
                     (join-Path -Path (scd -Print . 2>$null) -ChildPath "bin"),
                     (join-Path -Path (scd -Print . 2>$null) -ChildPath "bin/Debug"),
                     (join-Path -Path (scd -Print . 2>$null) -ChildPath 'bin/Release')) {
        $cmd = Join-Path -Path $dir -ChildPath "rdm-$command"
        if (Test-Path -Path $cmd) {
            & $cmd @Script:args
            return
        }
    }
    Write-Error "Failed to find command rdm-$command" -ErrorAction stop
}

Try {
    parse_cmd_line
    run_make
    make_link
    run_command
}
Catch {
    Write-Error $_
    exit 1
}
