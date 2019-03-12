ECHO OFF
SETLOCAL
REM ~ ###################################################################################################################
REM ~ Searchable Image PDF Creat-O-Mat 
SET VERSION=1.0.2
REM ~ This script creates a searchable PDF out of a PDF with one or more scanned pages. It is possible to drag and drop one or multiple PDF files onto this batch file to start the process.
REM ~ But you can use the command line (<script name> [pdf filename #1] [pdf filename #2] ... [pdf filename #n]) too.
REM ~ 
REM ~ Author: TB / License: MIT
REM ~ 
REM ~ Prerequisites:
REM ~ ImageMagick (7.0.8-27 and newer) https://imagemagick.org/ | License: https://imagemagick.org/script/license.php
REM ~ Ghostscript (9.x) https://www.ghostscript.com/
REM ~ Tesseract (4.0 and newer) https://github.com/tesseract-ocr/tesseract/wiki | http://www.apache.org/licenses/LICENSE-2.0
REM ~ OS: Microsoft Windows 7 (with PowerShell); 8; 8.1
REM ~ 
REM ~ Preferences:
REM ~ (leave no whitespace between the foldername and the '=' / do not use "):
SET IMAGEMAGIC=C:\Program Files (x86)\ImageMagick\magick.exe
SET TESSERACT=C:\Program Files (x86)\Tesseract-OCR\tesseract.exe
REM ~ SRCLANG shall contains the abbreviations of the installed Tesseract languages [default: eng]. Multiple languages e.g.: deu+eng - see https://github.com/tesseract-ocr/tesseract/wiki/Data-Files
SET SRCLANG=eng
REM ~ RESULTFOLDER is the folder where the searchable PDF will be stored (%CD% is the directory which contains this script) [default: %CD%\results]
SET RESULTFOLDER=%CD%\searchable_PDF
REM ~ TMPFOLDER is the folder where the extracted image files will be stored temporaly (the folder will be created and removed automatically during each run) [default: %CD%\temp]
SET TMPFOLDER=%CD%\temp
REM ~ ###################################################################################################################

REM ~ clear the screen (/ the command line window)
cls
ECHO OFF

REM ~  command line window candy: blue background color / white font color (not in Windows 10)
COLOR 1F

ECHO ### Searchable Image PDF Creat-O-mat %VERSION% ###

REM ~ Checking the preferences
REM ~ Does the ImageMagick location exist?
IF NOT EXIST "%IMAGEMAGIC%" (
	ECHO The ImageMagick location seems to be wrong. Please check the preferences.
	GOTO :SCRIPTEND
)
REM ~ Does the Tesseract location exist?
IF NOT EXIST "%TESSERACT%" (
	ECHO The Tesseract location seems to be wrong. Please check the preferences.
	GOTO :SCRIPTEND
)
REM ~ Is the Tesseract langauge package abbrevation of the correct pattern? 
FOR /F "usebackq tokens=*" %%i IN (`PowerShell -noninteractive -NoProfile "&{ '%SRCLANG%' | Select-String -Pattern '^([a-z]{3}_?([a-z]{3})?)(\+([a-z]{3}_?([a-z]{3})?))*$' -Quiet}"`) DO SET RST=%%i
IF /I NOT "%RST%" == "true" (
	ECHO The language settings seem to be wrong. Please check the preferences.
	GOTO :SCRIPTEND
)

REM ~ IF there is no subfolder e.g. temp\ (for the extracted pictures) THEN create it
IF NOT EXIST "%TMPFOLDER%" (
	MKDIR "%TMPFOLDER%"
	IF %ERRORLEVEL% GEQ 1 (
		ECHO Unable to create %TMPFOLDER%
		GOTO :SCRIPTEND
	)
)
REM ~ IF there is no subfolder for the searchable PDF files THEN create it
IF NOT EXIST "%RESULTFOLDER%" (
	MKDIR "%RESULTFOLDER%"
	IF %ERRORLEVEL% GEQ 1 (
		ECHO Unable to create %RESULTFOLDER%
		GOTO :SCRIPTEND
	)
)
REM ~ IF the first argument given to this script is empty THEN jump to the end of the loop and the script
IF "%~1" == "" (
	ECHO "Please, drag and drop a PDF with a scanned page onto this file OR write its filename with a whitespace behind filename of the script."
	GOTO :LOOPEND
) else (
	REM ~ Count the arguments given to this script
	REM ~ source: https://en.wikibooks.org/wiki/Windows_Programming/Programming_CMD#Command-Line_Interfacing
	set ARGCOUNT=0
	for %%x in (%*) do set /A ARGCOUNT+=1
	
	REM ~ Init the file counter
	set /a AMOUNT_OF_FILES=1
)
:LOOP
ECHO ### File %AMOUNT_OF_FILES% / %ARGCOUNT% ###
ECHO "%~1"

REM ~ IF the file does not exist THEN skip it or ELSE do the whole process
IF NOT EXIST "%~1" (
	ECHO The file "%~1" does not exist.
) ELSE (
	REM ~ Start the ImageMagic to extract the scanned page from the PDF file
	ECHO Extracting the page^(s^) from the PDF file ...
	"%IMAGEMAGIC%" -density 600 -units pixelspercentimeter -quality 75 "%~1" "%TMPFOLDER%\output_%AMOUNT_OF_FILES%-Seite_%%03d.png"
	ECHO DONE
	
	for /R "%TMPFOLDER%" %%f in (output_%AMOUNT_OF_FILES%-Seite_*.png) do (
		echo %TMPFOLDER%\%%~nf.png >> "%TMPFOLDER%\pageimagefilenames.txt"
	)
	
	REM ~ Start the OCR program (input: a picture file with scanned text / output: a searchable PDF file )
	"%TESSERACT%" -l deu "%TMPFOLDER%\pageimagefilenames.txt"  "%RESULTFOLDER%\%~n1" pdf

	REM ~ Delete the extratcted picture files and the file list from the temp-folder
	DEL "%TMPFOLDER%\output_%AMOUNT_OF_FILES%-Seite_*.png"
	DEL "%TMPFOLDER%\pageimagefilenames.txt"
)
SET /a "AMOUNT_OF_FILES=%AMOUNT_OF_FILES% + 1"

REM ~ `SHIFT` fills '%1' with the content of the second argument (`%2`), %2 with the content of third argument (`%3`) and so on
SHIFT

REM ~ IF the AMOUNT_OF_FILES dragged onto this .bat is smaller or equal to the total amount of file/arguments AND the next argument is not empty string THEN repeat the last step again. (Otherwise continue to the end of the script.)
IF %AMOUNT_OF_FILES% LEQ %ARGCOUNT% IF NOT "%~1" == "" (
	GOTO :LOOP
)
:LOOPEND
ECHO ### END ###

REM ~ remove the temp folder
RMDIR "%TMPFOLDER%"

:SCRIPTEND
ENDLOCAL

REM ~ keep the command line window open
cmd /k
