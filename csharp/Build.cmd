@setlocal
@ECHO off

SET CMDHOME=%~dp0
@REM Remove trailing backslash \
set CMDHOME=%CMDHOME:~0,-1%

@REM Set some .NET directory locations required if running from PowerShell prompt.
if "%FrameworkDir%" == "" set FrameworkDir=%WINDIR%\Microsoft.NET\Framework
if "%FrameworkVersion%" == "" set FrameworkVersion=v4.0.30319

SET MSBUILDEXEDIR=%FrameworkDir%\%FrameworkVersion%
SET MSBUILDEXE=%MSBUILDEXEDIR%\MSBuild.exe
SET MSBUILDOPT=/verbosity:minimal

if "%builduri%" == "" set builduri=Build.cmd

set PROJ_NAME=SparkCLR
set PROJ=%CMDHOME%\%PROJ_NAME%.sln

@echo ===== Building %PROJ% =====

@echo Restore NuGet packages ===================
SET STEP=NuGet-Restore

nuget restore

@if ERRORLEVEL 1 GOTO :ErrorStop

@echo Build Debug ==============================
SET STEP=Debug

SET CONFIGURATION=%STEP%

SET STEP=%CONFIGURATION%

"%MSBUILDEXE%" /p:Configuration=%CONFIGURATION% %MSBUILDOPT% "%PROJ%"
@if ERRORLEVEL 1 GOTO :ErrorStop
@echo BUILD ok for %CONFIGURATION% %PROJ%

@echo Build Release ============================
SET STEP=Release

SET CONFIGURATION=%STEP%

"%MSBUILDEXE%" /p:Configuration=%CONFIGURATION% %MSBUILDOPT% "%PROJ%"
@if ERRORLEVEL 1 GOTO :ErrorStop
@echo BUILD ok for %CONFIGURATION% %PROJ%

if EXIST %PROJ_NAME%.nuspec (
  @echo ===== Build NuGet package for %PROJ% =====
  SET STEP=NuGet-Pack

  powershell -f %CMDHOME%\..\build\script\nugetpack.ps1
  @if ERRORLEVEL 1 GOTO :ErrorStop
  @echo NuGet package ok for %PROJ%
)

@echo ===== Build succeeded for %PROJ% =====

@GOTO :EOF

:ErrorStop
set RC=%ERRORLEVEL%
if "%STEP%" == "" set STEP=%CONFIGURATION%
@echo ===== Build FAILED for %PROJ% -- %STEP% with error %RC% - CANNOT CONTINUE =====
exit /B %RC%
:EOF
