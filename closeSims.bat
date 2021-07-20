@echo off
tasklist /fi "imagename eq XVIIx64.exe" | find ":" > nul
if errorlevel 1 taskkill /f /im "XVIIx64.exe" > nul
exit