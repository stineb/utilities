#!/usr/bin/python
#
# ocr.py
#
# based on jpg2tiff.py and tif2txt.py
#
# written by Tyler W. Davis
# created: 2011-02-17
# updated: 2018-03-06
#
# ~~~~~~~~~~~~
# description:
# ~~~~~~~~~~~~
# This script converts JPG files in the working directory to plain text
# 1. Processes JPG images with a background noise filter (requires imagemagick)
#    and saves the processed JPG files with a "_m" extension (i.e., preserving
#    the original JPG files).
# 2. Converts processed JPG files to TIF image format (required for OCR).
# 3. Converts TIF images to plain text
#
# ~~~~~~
# notes:
# ~~~~~~
# These image processing functions depend on imagemagick
#    http://www.imagemagick.org
# which is a freeware for Windows, Mac and Linux. Other libraries that should
# be installed include: libtiff4 (TIFF library), libjpeg62 (JPEG runtime
# library), libpng12-0 (PNG runtime library), zliblg (runtime compression
# library).
#
# The OCR processing requires the package tesseract, which was originally
# developed by HP and is currently being maintained by Google. To download the
# OCR software on Linux machines, use a package manager and search for
# 'tesseract-ocr' and include any languages you require (e.g.,
# tesseract-ocr-eng for English). More information regarding the
# current state of tesseract OCR can be found at the Google code website:
#    http://code.google.com/p/tesseract-ocr/
#
# ~~~~~~~~~~
# changelog:
# ~~~~~~~~~~
# 11.03.10
# - added threshold option to monochrome function
# - added language option to totxt function
# 14.11.24
# - updated function doc strings
# 14.11.26
# - implemented glob for file searching
# 15.11.13
# - PEP8 style fixes
# 16.03.23
# - updated find files
# - added grayscale utility function
# 18.03.06
# - fixed issue with hardcoded file extensions
# - fixed function calls in main
# - added new modules
# - created check function for tesseract
#
###############################################################################
# IMPORT MODULES:
###############################################################################
import glob
import os
import subprocess
import sys


###############################################################################
# FUNCTIONS
###############################################################################
def check_tesseract():
    """Checks if tesseract is installed and working"""
    try:
        if sys.version_info >= (3, 5):
            return subprocess.run(
                ['tesseract', '-v'], stdout=subprocess.PIPE).returncode
        else:
            return subprocess.call(
                ['tesseract', '-v'], stdout=subprocess.PIPE)
    except:
        return -1


def findfiles(my_dir=".", my_ext=".jpg"):
    """
    Name:     findfiles
    Input:    - [optional] str, directory name (my_dir)
              - [optional] str, file extension (my_ext)
    Output:   glob.glob list
    Features: Returns a list of file names the local directory based on the
              given search file extension
    """
    path = os.path.join(my_dir, "*%s" % (my_ext))
    my_list = glob.glob(path)
    return (my_list)


def grayscale(myjpg, myext=".jpg"):
    """
    Name:     grayscale
    Input:    str, image file name (myjpg)
              - [optional] str, file extension (my_ext)
    Output:   None.
    Features: Processes JPG image to grayscale.
    """
    jpgbase = ""
    if myjpg.endswith(myext):
        # jpgbase holds the file name without the extension
        jpgbase = myjpg[:-len(myext)]

    mycmd = ("convert -type Grayscale " + myjpg + " " + jpgbase + "_y" + myext)
    os.system(mycmd)


def monochrome(myjpg, thresh=90, myext=".jpg"):
    """
    Name:     monochrome
    Input:    -str, image file name (myjpg)
              -int, threshold value (thresh)
              - [optional] str, file extension (myext)
    Output:   None.
    Features: Processes JPG image with text with threshold filter to remove
              background noise.
    """
    jpgbase = ""
    if myjpg.endswith(myext):
        # jpgbase holds the file name without the extension
        jpgbase = myjpg[:-len(myext)]

    mycmd = ("convert -threshold " + str(thresh) + "% " +
             myjpg + " " + jpgbase + "_m" + myext)
    os.system(mycmd)


def totif(myjpg, myext=".jpg"):
    """
    Name:     totif
    Input:    - str, image file name (myjpg)
              - [optional] stre, file extension (myext)
    Output:   None.
    Features: Converts JPG image to TIF format
    """
    jpgbase = ""
    if myjpg.endswith(myext):
        jpgbase = myjpg[:-len(myext)]

    mycmd = "convert " + myjpg + " " + jpgbase + ".tif"
    os.system(mycmd)


def totxt(mytif, lang="eng"):
    """
    Name:     totxt
    Input:    -str, image file name (mytif)
              -str, OCR language (lang)
    Output:   None.
    Features: Converts TIF image file to TXT using tesseract OCR
    """
    myext = ".tif"
    mybase = ""
    if mytif.endswith(myext):
        mybase = mytif[:-len(myext)]

    mycmd = "tesseract " + mytif + " " + mybase + " -l " + lang
    os.system(mycmd)

###############################################################################
# MAIN
###############################################################################
if __name__ == '__main__':
    my_fext = ".png"
    my_dir = "./"
    my_jpgs = findfiles(my_dir, my_fext)

    if check_tesseract() == 0 and my_jpgs:
        # Process JPGs with noise filter:
        for name in my_jpgs:
            monochrome(name, 75, my_fext)

        # Convert JPGs to TIFs
        my_jpg_ms = findfiles(my_dir, '_m' + my_fext)
        for name in my_jpg_ms:
            totif(name, my_fext)

        # Convert TIFs to text:
        my_tifs = findfiles(my_dir, '_m.tif')
        for name in my_tifs:
            totxt(name)
    else:
        print("Did not find any image files to process!")
