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
    - fill in the correct (absolute) folder of the ImageMagick, Ghostscript and Tesseract executable files at the beginning of the file.
    - edit the source language if necessary. You can set one or multiple languages Tesseract should look for in the scanned documents. (BTW: there different types of training data file for Tesseract. These seem to be a good choice https://github.com/tesseract-ocr/tessdata_best )
    - Save the changes
### Usage
* Drag and drop one or multiple PDF files onto this batch file to start the process 

  or

* Use the commandline window to start the script _<script filename> [pdf filename #1] [pdf filename #2] ... [pdf filename #n]_

### The Process
- The script uses Imagemagick and Ghostscript to extract the sacanned pages from the PDF file and store them tempararily in a subfolder the current batch file location.
- Imagemagick will then be used to deskew the image files in order to get better OCR results (there is an option the prevent that).
- The temporary image files will then processed by Tesseract which creates a new PDF file with a searchable text layer.
- Afterwards Ghostscript will be used to repack the PDF file in order to get smaller file (there is an option the prevent that). 
- The batch file will create also a further subfolder (\searchable_PDF) to store the searchable PDF files there.
