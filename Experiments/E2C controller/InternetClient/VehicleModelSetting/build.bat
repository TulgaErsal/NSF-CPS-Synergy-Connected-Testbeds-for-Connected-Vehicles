@ECHO OFF
CLS
COLOR 1B
TITLE 20-sim S-Function build script

SET CURPATH=%~dp0
SET MEX="mex.bat"

ECHO ------------------------------------------------------------
ECHO 20-sim to Simulink S-Function build script
ECHO ------------------------------------------------------------
ECHO Model: VESIM orig
ECHO Exported submodel: ShiftLogic
ECHO ------------------------------------------------------------
ECHO Calling the MATLAB "mex" compiler...

cmd /C %MEX% %*

ECHO.
ECHO ------------------------------------------------------------

IF %ERRORLEVEL% EQU 1 (
	ECHO Compilation failed.
	ECHO Make sure that the Matlab %MEX% compiler is in your PATH
	ECHO You can manually restart this build script by calling "%~dp0build.bat"
	goto end
)

IF %ERRORLEVEL% NEQ 0 (
	ECHO Compilation failed.
	ECHO The MEX compiler returned an error.
	goto end
)

ECHO Simulink S-Function export for submodel 'ShiftLogic' succeeeded.
ECHO You can find the generated S-function named
ECHO    ShiftLogic
ECHO in
ECHO    %~dp0 

:end
ECHO ------------------------------------------------------------
pause
