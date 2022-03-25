#!/usr/bin/pwsh

# Process command-line options that will be passed to pc-lint
# #
function process_options
{
    for ($ii = 0; $ii -lt $script:args.count; $ii++)
    {
        $arg = $script:args[$ii]
        ##Write-Host "Arg is ${arg}"

        if ($arg.substring(0, 2) -eq '-I')
        {
            $script:all_args = -join("$script:all_args", '-I', (Resolve-Path -path $arg.substring(2)))
        }
        else 
        {
            $script:all_args = -join($script:all_args, $arg)
        }
        $script:all_args = -join($script:all_args, ' ')
    }
}

# Build the full command string and execute it
#
function execute_lint
{
    $lint_command = -join($ENV:LINT_ROOT, '/lint-nt.exe', ' ')           ## PC-Lint executable
    $lint_command = -join($lint_command, '-I', $ENV:LINT_ROOT, '/lnt/ ') ## PC-Lint config file location
    $lint_command = -join($lint_command, 'co-mswin.lnt co-msc90.lnt ')   ## PC-Lint config files
    $lint_command = -join($lint_command, '-u -b ')                       ## Suppress banner
    $lint_command = -join($lint_command, '"+os(', $outfile, ')" ')       ## Output file specification
    $lint_command = -join($lint_command, $all_args)
    
    #Write-Host "lint_command = $lint_command"
    Invoke-Expression $lint_command
}

try
{
    $script:outfile = (Split-Path -Path $pwd -Leaf) + '.lnt'
    if ($script:args.count -eq 1 -and $script:args[0] -eq '--setup')
    {
        if (Test-Path $outfile)
        {
            Remove-Item $outfile
        }
    }
    else
    {
        $script:all_args = ''

        process_options
        execute_lint
    }
}
catch
{
    Write-Error $_
    exit 1
}
