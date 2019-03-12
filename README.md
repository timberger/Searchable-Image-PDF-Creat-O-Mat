# Searchable-Image-PDF-Creat-O-Mat
This [batch script](https://en.wikipedia.org/wiki/Batch_file) creates a searchable PDF out of a PDF with one or more scanned pages by using the image handling software [ImageMagick](https://en.wikipedia.org/wiki/ImageMagick) and the [OCR](https://en.wikipedia.org/wiki/Optical_character_recognition) software [Tesseract](https://en.wikipedia.org/wiki/Tesseract_(software)).
It is possible to drag and drop one or multiple PDF files onto this batch file to start the process. But it is also possible to use the command line too.

## Prerequisites:
* ImageMagick (7.0.8-27 and newer) https://imagemagick.org/
* Ghostscript (9.xx) https://www.ghostscript.com/
* Tesseract (4.0 and newer) https://github.com/tesseract-ocr/tesseract/wiki
* Operating System: Microsoft Windows 7 (with PowerShell); 8; 8.1; 10 ? (untested)

## How to use it
### Installation
* Install ImageMagick
* Install Ghostscript
* Install Tesseract
* Put the file into the folder where you or your scanner stores the scanned PDF files
* Open the batch file with a text editor e.g. [Notepad](https://en.wikipedia.org/wiki/Microsoft_Notepad) or [Scite](https://en.wikipedia.org/wiki/SciTE) and 
    - fill in the correct (absolute) folder of the ImageMagick and Tesseract executable files at the beginning of the file.
    - edit the source language if necessary. You can set one or multiple languages Tesseract should like for in the scanned documents.
    - Save the changes
### Usage
* Drag and drop one or multiple PDF files onto this batch file to start the process 

  or

* Use the commandline window to start the script _<script filename> [pdf filename #1] [pdf filename #2] ... [pdf filename #n]_

The script will create a subfolder at the current batch file location to store the image files which will be extracted from the PDF files. It will also create a further subfolder (\searchable_PDF). The script will store the searchable PDF files there.
