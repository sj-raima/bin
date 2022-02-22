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
$Script:colour_command = '-c "colorscheme elflord"'

if ($Script:args.count -eq 0)
{
    Start-Process "$Script:vi_exec" -ArgumentList @($Script:colour_command)
}
else
{
    $Script:file_name = $args[0]
    Start-Process "$Script:vi_exec" -ArgumentList @($Script:colour_command, $Script:file_name)
}
