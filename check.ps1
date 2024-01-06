#!/usr/bin/pwsh

& (Join-Path -Path (~/bin/rcd -Print) -ChildPath 'check.ps1') @args
