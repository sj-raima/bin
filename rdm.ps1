#!/usr/bin/pwsh

# Print the help text
Function print_help {
    Write-Host "Usage: rdm [-Make] [-Link] [-h|-Help] <command> <arguments>"
    Write-Host
    Write-Host "    -h|-Help    Print this help"
    Write-Host "    -Make       Build the tool before executing it"
    Write-Host "    -Link       Make a symbolic link for the command to the current"
    Write-Host "                working directory"
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
#    $make      Set if the command should be made using make or nmake
#    $link      Should we make a link for the command
#
Function parse_cmd_line {
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
    $dir = (scd -Print "rdm-$command") 2>$null
    if (-Not $?) {
        Write-Error "Failed to find command rdm-$command" -ErrorAction stop
    }
    & (Join-Path -Path $dir -ChildPath "rdm-$command") @Script:args
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
