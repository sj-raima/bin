#!/usr/bin/pwsh

& (Join-Path -Path (rcd -Print) -ChildPath 'check.ps1') @args
