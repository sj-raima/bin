#!/usr/bin/pwsh

$orig_dir = $dir = $pwd

while ($dir -ne "") {
    if ((Test-Path -Path (Join-Path -Path $dir -ChildPath '.git'))) {
        if (-Not (Test-Path -Path (Join-Path -Path $dir -ChildPath 'prebuild.pl'))) {
            Write-Error "Not inside a project with a prebuild.pl script" -ErrorAction stop
        }
        try {
            cd $dir
            perl prebuild.pl @Script:args
            if (-Not $?) {
                Write-Error "Running prebuild.pl failed" -ErrorAction stop
            }
        }
        finally {
            cd $orig_dir
        }
        exit 0
    }
    $dir = Split-Path $dir -Parent
}

Write-Error "Not inside a project" -ErrorAction stop
