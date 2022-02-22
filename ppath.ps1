## Prepend the specified path to the existing PATH environment

# If the command has no arguments, prepend the current working directory
if ($args.count -eq 0)
{
    $arg = Get-Location
}
elseif ($args.count -eq 1)
{
    $arg = $args[0]
}
else
{
    $Host.UI.WriteErrorLine("PPATH only takes one argument")
    exit 1
}

if ($null -eq $ENV:PATH)
{
    $ENV:PATH = "$arg"
}
else
{
    $ENV:PATH = "$arg;$ENV:PATH"
}
