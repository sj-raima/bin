@echo off

powershell.exe -executionpolicy remotesigned -File %USERPROFILE%\sj_bin\pclint.ps1 %*

exit /b
