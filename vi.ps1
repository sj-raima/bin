## $ENV:HOME="C:\Users\dtoyama"

if ($null -eq $ENV:vi_dir)
{
    $Script:vi_dir = "C:\Apps\VIM\vim82"
}
else
{
    $Script:vi_dir = $ENV:vi_dir
}

$Script:vi_exec = "$Script:vi_dir\gvim.exe"
$Script:colour_scheme = 'elflord'
## $Script:colour_command = '-c "colorscheme elflord"'

if ($Script:args.count -eq 0)
{
    Start-Process "$Script:vi_exec" -ArgumentList @($Script:colour_command)
    Start-Process "$Script:vi_exec" -ArgumentList "-c `"colorscheme $SCRIPT:colour_scheme`""
}
else
{
    $Script:file_name = $args[0]
    #Start-Process "$Script:vi_exec" -ArgumentList @($Script:colour_command, $Script:file_name)
    Start-Process "$Script:vi_exec" -ArgumentList "-c `"colorscheme $SCRIPT:colour_scheme`"", "$SCRIPT:file_name"
}
