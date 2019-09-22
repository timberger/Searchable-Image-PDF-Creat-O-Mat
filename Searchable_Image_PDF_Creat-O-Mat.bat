ECHO OFF
SETLOCAL
REM ~ ###################################################################################################################
REM ~ Searchable Image PDF Creat-O-Mat 
SET VERSION=1.2
REM ~ This script creates a searchable PDF out of a PDF with one or more scanned pages. It is possible to drag and drop one or multiple PDF files onto this batch file to start the process.
REM ~ But you can use the command line (<script name> [pdf filename #1] [pdf filename #2] ... [pdf filename #n]) too.
REM ~ 
REM ~ Author: TB / License: MIT / https://github.com/timberger/Searchable-Image-PDF-Creat-O-Mat/
REM ~ 
REM ~ Prerequisites:
REM ~ ImageMagick (7.0.8-27 and newer) https://imagemagick.org/ | License: https://imagemagick.org/script/license.php
REM ~ Ghostscript (9.x) https://www.ghostscript.com/
REM ~ Tesseract (4.0 and newer) https://github.com/tesseract-ocr/tesseract/wiki | http://www.apache.org/licenses/LICENSE-2.0
REM ~ OS: Microsoft Windows 7 (with PowerShell); 8; 8.1
REM ~ 
REM ~ Preferences:
REM ~ (leave no whitespace between the foldername and the '=' / do not use "):
SET IMAGEMAGIC=C:\Program Files\ImageMagick\magick.exe
SET GHOSTSCRIPT=C:\Program Files\gs\gs9.23\bin\gswin64c.exe
SET TESSERACT=C:\Program Files (x86)\Tesseract-OCR\tesseract.exe
REM ~ SRCLANG shall contain the abbreviations of the installed Tesseract languages which shall be searched for in the scanned files [default: eng]. Multiple languages e.g.: deu+eng - see https://github.com/tesseract-ocr/tesseract/wiki/Data-Files
SET SRCLANG=deu
REM ~ The scanned page can be deskewed before it is processed with Tesseract or not [default: true / alternative: false]. It is recommended to deskew the sanned page because it increases the success rate of the OCR software. But it will take more time.
SET DESKEW=true
REM ~ RESULTFOLDER is the folder where the searchable PDF will be stored (%CD% is the directory which contains this script) [default: %CD%\results]
SET RESULTFOLDER=%CD%\searchable_PDF
REM ~ TMPFOLDER is the folder where the extracted image files will be stored temporaly (the folder will be created and removed automatically during each run) [default: %CD%\temp]
SET TMPFOLDER=%CD%\temp
REM ~ After Imagemagick and Tesseract have created the new PDF file it has usually a bigger file size. But it can be re-packed with Ghostscript which compresses the image file to a certain resolution e.g. screen (72dpi), ebook (150dpi), printer(300dpi), prepress(300dpi+colorpreserving)
SET REPACKPROFILE=printer
REM ~ ###################################################################################################################

REM ~ clear the screen (/ the command line window)
CLS
ECHO OFF

REM ~ starting the stop watch
SET StartPosition=%time:~0,8%

REM ~ command line window candy: blue background color / white font color (not in Windows 10)
COLOR 1F

ECHO ### Searchable Image PDF Creat-O-Mat %VERSION% ###

REM ~ Checking the preferences
REM ~ Does the ImageMagick location exist?
IF NOT EXIST "%IMAGEMAGIC%" (
	ECHO The ImageMagick location seems to be wrong. Please check the preferences.
	GOTO :SCRIPTEND
)
REM ~ Does the ImageMagick location exist?
IF NOT EXIST "%GHOSTSCRIPT%" (
	ECHO The Ghostscript location seems to be wrong. Please check the preferences.
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
	ECHO Please, drag and drop a PDF with a scanned page onto this file OR write its filename with a whitespace behind filename of the script.
	GOTO :LOOPEND
) ELSE (
	REM ~ Count the arguments given to this script
	REM ~ source: https://en.wikibooks.org/wiki/Windows_Programming/Programming_CMD#Command-Line_Interfacing
	SET ARGCOUNT=0
	FOR %%x IN (%*) DO SET /A ARGCOUNT+=1
	
	REM ~ Init the file counter
	SET /a AMOUNT_OF_FILES=1
)
:LOOP
ECHO ### File %AMOUNT_OF_FILES% / %ARGCOUNT% ###
ECHO %~1

REM ~ Resolution which Imagemagick and Tesseract shall use to handle the images (in DPI / default:300)
SET RESDPI=300
		
REM ~ IF the file does not exist THEN skip it or ELSE do the whole process
IF NOT EXIST "%~1" (
	ECHO The file "%~1" does not exist.
) ELSE (
	REM ~ Start the ImageMagic to extract the scanned page from the PDF file
	ECHO Extracting the page^(s^) from the PDF file ^(density: %RESDPI% dpi^) ...
	"%IMAGEMAGIC%" -density %RESDPI% -units pixelsperinch -quality 85 "%~1" "%TMPFOLDER%\output_%AMOUNT_OF_FILES%-page_%%03d.png"
	ECHO DONE
	
	REM ~ deskew the rerieved image(s) OR not and just build the file with filenames of the retrieved pages 
	IF "%DESKEW%"=="true" (
		FOR /R "%TMPFOLDER%" %%f IN (output_%AMOUNT_OF_FILES%-page_*.png) DO (
			ECHO Deskewing page %%~nf.png
			REM ~ -set option:deskew:auto-crop true -background white -sharpen 0x1.0 -sharpen 0.25x0.5
			"%IMAGEMAGIC%" %TMPFOLDER%\%%~nf.png -deskew 80 %TMPFOLDER%\%%~nf_ds.png
			ECHO %TMPFOLDER%\%%~nf_ds.png >> "%TMPFOLDER%\pageimagefilenames.txt"
		)
		ECHO DONE
	) ELSE (
		FOR /R "%TMPFOLDER%" %%f IN (output_%AMOUNT_OF_FILES%-page_*.png) DO (
			ECHO %TMPFOLDER%\%%~nf.png >> "%TMPFOLDER%\pageimagefilenames.txt"
		)
	)
	
	REM ~ Start the OCR program (input: a picture file with scanned text / output: a searchable PDF file )
	"%TESSERACT%" -l %SRCLANG% --dpi %RESDPI% "%TMPFOLDER%\pageimagefilenames.txt" "%TMPFOLDER%\%~n1" pdf
	
	REM ~ Repack the new PDF file with the text layer OR just move it from the TMP folder to the result without repacking
	IF "%REPACKPROFILE%"=="screen" GOTO :REPACKING
	IF "%REPACKPROFILE%"=="ebook" GOTO :REPACKING
	IF "%REPACKPROFILE%"=="printer" GOTO :REPACKING
	IF "%REPACKPROFILE%"=="prepress" GOTO :REPACKING
	REM ~ IF REPACKPROFILE is not equal to screen, ebook, printer or prepress
		move "%TMPFOLDER%\%~n1.pdf" "%RESULTFOLDER%\%~n1.pdf"
	:REPACKING
		ECHO Repacking the output PDF file ^(profile: %REPACKPROFILE%^) ...
		"%GHOSTSCRIPT%" -q -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/%REPACKPROFILE% -dNOPAUSE -dBATCH -dQUIET -sOutputFile="%RESULTFOLDER%\%~n1.pdf" "%TMPFOLDER%\%~n1.pdf"
		DEL "%TMPFOLDER%\%~n1.pdf"
		ECHO DONE

	REM ~ Delete the extratcted picture files and the file list from the temp-folder
	DEL "%TMPFOLDER%\output_%AMOUNT_OF_FILES%-page_*.png"
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

REM ~ remove the temp folder
RMDIR "%TMPFOLDER%"

REM ~ setting the colors back to default
COLOR 

REM ~ determining the duration (with the help of https://stackoverflow.com/questions/42603119/arithmetic-operations-with-hhmmss-times-in-batch-file/42603985#42603985)
SET EndPosition=%time:~0,8%
SET /A "ss=(((1%EndPosition::=-100)*60+1%-100)-(((1%StartPosition::=-100)*60+1%-100)"
SET /A "hh=ss/3600+100,ss%%=3600,mm=ss/60+100,ss=ss%%60+100"
ECHO Duration: %hh:~1%:%mm:~1%:%ss:~1%
ECHO ### END ###

:SCRIPTEND
ENDLOCAL

REM ~ keep the command line window open
CMD /k