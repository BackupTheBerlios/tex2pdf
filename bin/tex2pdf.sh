#!/bin/bash

#      tex2pdf - script for translating latex docs to pdf
#
#      Copyright (C) 2000 by Steffen Evers (tron@cs.tu-berlin.de)
#
#      This program is free software; you can redistribute it and/or modify
#      it under the terms of the GNU General Public License as published by
#      the Free Software Foundation; either version 2 of the License, or
#      (at your option) any later version.
#
#      This program is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#      GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public License
#      along with this program; if not, write to the Free Software
#      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Release History:
#
# Aug 13th, 2000 -- Release 1.2
#  * initial public version
#     (thanks to Matej Cepl helping me with the pdflatex stuff)
#     (thanks to Herbert Voss for helping me with the latex stuff)
#     (thanks to all the people who supported me with their feedback)
#
# Aug 14th, 2000 -- Release 1.3
#  * added command to rename ~/.lyx/lyxpipe.out and ~/.lyx/lyxpipe.in 
#     (thanks to Herbert Voss for this hint)
#  * converted the sed command to be suitable for a single line
#  * added check for number of command line arguments
#
# Sep 15th, 2000 -- Release 1.4
#  * added some reports while execution
#  * stopped rerunning pdflatex when there are no more warnings/errors
#     (thanks to Nicolas Marsgui for the idea and his patch)
#  * made sed commands work with GNU sed v3.02 and made them more readable
#     (thanks to Bruce Foster (bef@nwu.edu) for this patch)
#  * introduced environment variable for sed executable
#     (thanks to Bruce Foster for the idea and his patch) 
#  * added parameter section
#  * added the possibility to give pdflatex some additional options
#  * added check for required commands (sed, pdflatex, epstopdf)
#  * added existence check for images and tex document
#  * reduced output of pdflatex to warnings and errors
#
# Sep 20th, 2000 -- Release 1.5
#  * made command checking work on more systems and give advice
#  * stopped pdflatex to prompt for input (output redirection=> invisible!)
#  * some more status messages for pdflatex
#  * minor changes
#
# Oct 14th, 2000 -- Release 1.6
#  * added bibtex support
#     (thanks to Mark van Rossum for hinting to the problem)
#     (thanks to Matt Bandy for his patch)
#  * improved pdflatex error checking, hint to log file
#  * introduced paramter to set the location of the generated PDF document
#  * change working directory to document directory (for local images, etc.)
#     (thanks to Matt Bandy for his patch)
#  * put in tex command before 'makeletter' instead 'makeatother' (fixes problem
#    with apacite package - requires different order)
#     (thanks to Mark van Rossum for this patch)
#  * introduced paramters to specifiy title, author and link colors
#     (thanks to Matt Bandy for this patch)
#  * minor changes
#
# Oct 15th, 2000 -- Release 1.7
#  * fixed checkCommand function - buggy output redirection generated file '1'
#     (thanks to Nicolas Marsgui for this patch)
#
# Oct 20th, 2000 -- Release 1.8 beta 1
#  * fixed permission problems with multiple users (log-files)
#     (thanks to Garrick Chien Welsh for this patch)
#
# Jan 14th, 2001 -- Release 1.8 beta 2 
#  * added conversation of pictures in included TeX files
#     (thanks to Stacy J. Prowell <sprowell@cs.utk.edu> for his patch)
#  * corrected sed expressions to check for backslash 
#  * introduced function section (code more structured)
#  * added support for pstex_t files with included EPS image
#     (thanks to Pavel Sedivy for his patch)
#  * added check if TeX file is newer than LyX document
#     (thanks to Pavel Sedivy for this idea)
#  * minor changes
#
# Jan 21st, 2001 -- Release 1.8 beta 3 
#  * modified LyX export command to work with LyX 1.1.6
#     (thanks to Stacy J. Prowell <sprowell@cs.utk.edu> for this hint)
#
# Mar 02nd, 2001 -- Release 1.8 beta 4 
#  * modified image searching to cover not only first image in a line
#     (thanks to Holger Daszler for this hint)
#
# Mar 09th, 2001 -- Release 1.8 
#  * included convert_pstex2pdf tmp files in clean up
#  * added support for PDF thumbnails
#     (thanks to Olaf Gabler for his patch)
#  * better code structure (more functions)
#  * minor changes
#
# Mar 11th, 2001 -- Release 2.0 beta 2
#  * renamed lyx2pdf script to tex2pdf to reflect change of functionality
#  * accept both: lyx and tex files
#     (thanks to Olaf Gabler for his patch)
#  * restructured the code - most code is now in functions
#  * fixed bug: only documents in current working directory have been found
#  * changed WHICHON in COMMANDCHECK
#  * minor changes
#
# Mar 14th, 2001 -- Release 2.0 beta 3
#  * bugfix: if the specified sed executable did not exist tex2pdf failed
#  * improved title and author handling: ignore text with included TeX tags
#  * scan for an input@path in the document and make it the working directory
#  * bugfix: sed command in getFileList could not handle files with a path
#  * additonal TeX code is now inserted before \begin{document}
#  * batchmode command is removed in TeX files to protect pdflatex execution
#  * introduced directory for log files that is cleaned up before execution
#  * cleaned up the code and other minor changes
#
# Mar 14th, 2001 -- Release 2.0
#  * Release 2.0 beta 3 becomes Release 2.0
#
# Apr 06th, 2001 -- Release 2.1
#  * bugfix: included graphics haven't been recognised with [...] parameter
#     (thanks to Ahmet Sekercioglu for the bug report)
#  * introduced parameters MINRUNNO, INSERTCOMMAND and CLEANLOGS
#  * bugfix: env variable in single quotes (handling of included TeX files)
#  * bugfix: TOC was not created as pdflatex has been running only once
#     (thanks to Richard for the bug report)
#  * bugfix: commented out \include and \bibliography have been processed
#     (thanks to Ahmet Sekercioglu for the bug report)
#  * added optional makeindex support (set MAKEINDEX=test to activate)
#     (thanks to Steffen Macke for his work)
#

MYRELEASE="2.1.0"

##### You will need pdftex and epstopdf for the generation!
##### See pdftex homepage for details: http://tug.org/applications/pdftex/
##### Have fun!!!

##### Parameters: Adjust them to your personal system

### pdftex package options: 
### see hyperref manual for more:/usr/share/texmf/doc/latex/hyperref/manual.pdf

# papersize of the resulting pdf document
# some possible values: a4paper, letterpaper, legalpaper, executivepaper
PAPERSIZE=a4paper

# use color for links in the resulting document
# options: 'true' or 'false'
COLORLINKS=true

# color to use for URLS in resulting document
# some possible values:  red, green, cyan, blue, magenta, black
URLCOLOR=blue

# color to use for citations in resulting document
# some possible values:  red, green, cyan, blue, magenta, black
CITECOLOR=red

# Title info for resulting document
# leave blank for LaTeX document title
TITLE=

# Author info for resulting document
# leave blank for LaTeX document author
AUTHOR=

### other parameters

# directory where the generated pdf file is stored
# no value means the same directory as the LaTeX file
PDFOUTDIR=

# the sed executable this script should use
# no value means script should use the sed in your path
SEDEXE=

# usage of bibtex
# possible values: 'yes' (always run bibtex), 'no' (never run bibtex), 
# 'test' (scan tex file for a bibtex entry and run it if required)
BIBTEX=test

# maximal number of runs for pdflatex
MAXRUNNO=6

# minimal number of runs for pdflatex
# This option can be used to force pdflatex to run at least MINRUNNO times even
# when tex2pdf cannot detect any more warnings or errors.
# This might help if there is no table of contents or other things are missing.
# possible values: 1 ... MAXRUNNO
MINRUNNO=3

# directory for log files
# CAUTION: All files in this directory will be deleted if you set CLEANLOGS=yes!
LOGDIR=/tmp/tex2pdf-$USER/

# log files for the output of pdflatex, bibtex and thumbpdf
PDFLOGFILE=${LOGDIR}pdflatex-$$.log
BIBTEXLOG=${LOGDIR}bibtex-$$.log
THUMBPDFLOG=${LOGDIR}thumbpdf-$$.log

# clean log directory before execution
# You might get problems with this when you run tex2pdf on several documents
# at the same time. So, if you want to be on the safe side set "no" and clean
# the log directory manually.
# possible values: 'yes', 'no' 
CLEANLOGS="no"

# additional options for pdflatex
PDFTEXOPTS=""

# Use which command to check for required executables
# possible values: 'yes', 'no' 
COMMANDCHECK="yes"

# use thumbpdf to include thumbnails of all PDF document pages
# requires ghostscript version 5.50 or higher to generate the thumbnails (PNG)
# see more informations: /usr/share/texmf/doc/pdftex/thumbpdf/readme.txt
# possible values: "yes" for thumbnails, "no" - without thumbnails
THUMB="no"

# suffix for tmp files that will be put in between the basename and suffix of
# the original file
# CAUTION: If you leave this blank you will overwrite the original files!
TMPBASESUFFIX=-pdf

# execution of the makeindex command for index handling
# this should fix the problem with a missing document index
# possible values: "test" - check for index file and if found call makeindex 
#                  "no" - never execute it
MAKEINDEX="no"

# sed command which is used to insert additional TeX commands in the LaTeX
# preamble
# try the following commands if you have strange errors or junk on the
# first PDF document page
# INSERTCOMMAND="/^[\]begin{document}$/i"
# INSERTCOMMAND="/^[\]makeatletter$/i"
INSERTCOMMAND="/^[\]documentclass\(\[[^]]*\]\)\?{.*}/a"


##### Functions

### Removing all temporary files

clean_up() {
   echo $MYNAME: Removing temporary files ... 
   [ -n "$TMPFILES" ] && rm $TMPFILES
   [ -n "$TMPBASE" ] && rm ${TMPBASE}.*
}

### Check arguments
# parameters ($@): all arguments that were passed to the script by the shell

check_arguments() {
   if [ $# -ne 1 ]
   then
      echo
      echo $MYNAME: Wrong number of arguments.
      echo
      echo "Usage: $MYNAME DOCUMENT.lyx"
      echo "       $MYNAME DOCUMENT.tex"
      echo
      exit 1
   fi
}

##### Make sure that specified file exists and is readable; abort if missing 
# parameter $1: file to check
# parameter $2: remark if check fails on specified file

check_file() {
   local MESSAGE=$2
   [ -z "$MESSAGE" ] && MESSAGE="Required file cannot be accessed!"

   if [ ! -f "$1" ]
   then
      echo
      echo "$MYNAME: Sorry. I cannot find '$1'."
      echo "$MESSAGE"
      clean_up
      echo "Aborting ..."
      echo
      exit 1
   elif [ ! -r "$1" ]
   then
      echo
      echo "$MYNAME: Sorry. File '$1' exists, but is not readable."
      echo "$MESSAGE"
      clean_up
      echo "Aborting ..."
      echo
      exit 1
   fi
}

### Check for required command with 'which'; abort if not found 
# parameter $1: command to check
# parameter $2: remark if specified command is not found

checkCommand() {
   WHICHRESULT=`which $1 2>&1`
   WHICHBASE=`basename "$WHICHRESULT"`
   if [ "$WHICHBASE" != "$1" ]
   then
      echo
      which $1
      echo
      echo "$MYNAME: Required command '$1' seems not to be in your path."
      if [ -n "$2" ]
      then
         echo "$2"
      fi
      echo "Aborting ..."
      exit 1
   fi
}

### check if the most important executables are installed on the system
# parameters: none

check_commands() {
   ### check for which command
   checkCommand which "You can switch off all command checks by setting COMMANDCHECK=no in the parameter section of $MYNAME."

   ### sed executable
   # GNU sed version 3.02 or higher is recommended
   # Download: ftp://ftp.gnu.org/pub/gnu/sed"
   if [ "$SEDEXE" = "sed" ]
   then
      checkCommand sed "You should get GNU sed 3.02 or later: ftp://ftp.gnu.org/pub/gnu/sed"
   fi
   
   ### pdftex executables
   # Homepage: http://tug.org/applications/pdftex
   checkCommand pdflatex "See pdftex homepage for details: http://tug.org/applications/pdftex"
   checkCommand epstopdf "See pdftex homepage for details: http://tug.org/applications/pdftex"

   if [ "$THUMB" = "yes" ]
   then
      checkCommand thumbpdf "You can switch off thumbpdf support by setting THUMB=no in the parameter section of $MYNAME."
   fi

   ### bibtex executable
   if [ "$BIBTEX" != "no" ]
   then
      checkCommand bibtex "You can switch off BibTeX support by setting BIBTEX=no in the parameter section of $MYNAME."
   fi
}

### generate LaTeX file from LyX document with LyX itself
# parameter ($1): Lyx document
# parameter ($2): Latex document

generate_tex_file() {
   local LYXDOC=$1
   local TEXDOC=$2

   ### Check if LyX file can be accessed
   check_file "$LYXDOC" "Cannot read the specified LyX document!"

   ### Check if LaTeX file exists and is newer than the LyX file
   if [ -f "$TEXDOC" -a "$TEXDOC" -nt "$LYXDOC" ]
   then
      echo
      echo "$MYNAME: LaTeX file is newer than LyX document '$LYXDOC'."
      echo "Using existing TeX file: $TEXDOC"
      echo "Remove it to force its new generation."
   else
      ### export LaTeX file with LyX (needs a display!)
      checkCommand lyx "Cannot generate LaTeX document without LyX!"
      echo
      echo $MYNAME: Exporting LaTeX file 
      [ -f $HOME/.lyx/lyxpipe.out ] && mv $HOME/.lyx/lyxpipe.out $HOME/.lyx/lyxpipe.out~
      [ -f $HOME/.lyx/lyxpipe.in ] && mv $HOME/.lyx/lyxpipe.in $HOME/.lyx/lyxpipe.in~
      [ -f $TEXDOC ] && mv $TEXDOC $TEXDOC~
      lyx --export latex $LYXDOC
      
      ### check if LaTeX file now really exists
      check_file $TEXDOC "The LaTeX document was not generated by LyX!"
   fi
}

### Build a list of all files which are included from the root file.
# This function recurses, and is maybe smart enough to detect cycles.
# One input parameter for this ($1): a tex file.
# Be sure to set FILES to the empty string prior to calling this.

getFileList() {
   # This is the cycle avoidance logic.
   flag=`echo $FILES | ${SEDEXE} -n "\W ${1}Wp"`
   if [ -z "$flag" ] ; then
      # Make sure the file can be accessed
      check_file $1 "Included TeX file seems not to be available. Path problem?"
      
      # Save the argument in the list of files.
      FILES="$FILES $1"

      # Get the list of files included by the argument.
      local IMPORTS=`${SEDEXE} -n "s/^[^%]*[\]include{\([^}]\+\)}.*$/\1.tex /p" $1`

      # Recurse.
      for file in $IMPORTS ; do
         getFileList $file
      done
   fi
}

### Convert all given EPS images to PDF
# parameters ($@): list of EPS images with relative path to working directoy

convert_eps2pdf() {
   IMAGES="$@"
   echo
   echo $MYNAME: Converting EPS images to pdf
   for image in $IMAGES
   do
      IMAGENAME=`basename $image`
      IMAGEPATH=`echo "$image" | ${SEDEXE} -n "s/^\(.*\)$IMAGENAME$/\1/p"`
      IMAGEBASE=`basename $IMAGENAME .eps`
      IMAGEBASE=`basename $IMAGEBASE .ps`

      #### check if image file really exists
      check_file ${IMAGEPATH}${IMAGENAME} "Could not convert included image."
   
      echo Converting image ${IMAGENAME} ...
      epstopdf -outfile=${IMAGEPATH}${IMAGEBASE}.pdf ${IMAGEPATH}${IMAGENAME}
      TMPFILES="$TMPFILES ${IMAGEPATH}${IMAGEBASE}.pdf"
   done
}

### Convert all given PSTEX_T files to PDF_T
# parameters ($@): list of PSTEX_T files with relative path to working directoy

convert_pstex2pdf() {
   PSTEXS="$@"
   echo
   echo $MYNAME: Converting PSTEX_T images to PDF
   for pstexfile in $PSTEXS
   do
      PSTEXNAME=`basename $pstexfile`
      PSTEXPATH=`echo "$pstexfile" | ${SEDEXE} -n "s/^\(.*\)$PSTEXNAME$/\1/p"`
      PSTEXBASE=`basename $PSTEXNAME .pstex_t`

      #### check if image file really exists
      check_file ${PSTEXPATH}${PSTEXNAME} "Could not convert included image."
   
      # descend into file
      echo Converting file ${PSTEXNAME} ...

      # create .pdf_t file
      sed -e "s/\(^[^%]*[\]includegraphics\(\[[^{]*\]\)\?{.*\.\)pstex\(.*$\)/\2pdf\3/g" ${PSTEXPATH}${PSTEXNAME} > "${PSTEXPATH}${PSTEXBASE}.pdf_t"
      
      # find included EPS image
      EPSIMAGE=`${SEDEXE} -n "s/^[^%]*[\]includegraphics\(\[[^{]*\]\)\?{\([^}]\+\)}.*$/\2/pg" ${PSTEXPATH}${PSTEXNAME}`
      EPSBASE=`basename $EPSIMAGE .pstex`

      # convert image to pdf
      epstopdf -outfile=${PSTEXPATH}${EPSBASE}.pdf ${PSTEXPATH}${EPSIMAGE}
      PDFIMAGES="$PDFIMAGES ${PSTEXPATH}${PSTEXBASE}.pdf"

      TMPFILES="$TMPFILES ${PSTEXPATH}${PSTEXBASE}.pdf_t ${PSTEXPATH}${PSTEXBASE}.pdf"
   done
}

### Converted included images to pdf and change the corresponding
### reference in the tmp-tex files
# parameter ($1): tex source file
# parameter ($2): tex target file

prepare_document() {
  
   ### set required variables 
   local TEXSOURCE="$1"
   local TARGETFILE="$2"

   echo
   echo "Preparing document: $TEXSOURCE."
   
   ##### Get EPS images from the source file
   echo
   echo "Scanning for EPS images (.eps/.ps):"
   EPSIMAGES=`${SEDEXE} -n "s/^[^%]*[\]includegraphics\(\[[^{]*\]\)\?{\([^}]\+\.\(e\)*ps\)}.*$/\2 /pg" $TEXSOURCE`
   if [ -n "$EPSIMAGES" ]
   then
      echo "$EPSIMAGES"
   else
      echo "None."
   fi
   
   ##### Get PSTEX_T files from the source file
   echo
   echo "Scanning for PSTEX_T files (.pstex_t):"
   PSTEXS=`${SEDEXE} -n "s/^[^%]*[\]input{\([^}]\+\.pstex_t\)}.*$/\1 /p" $TEXSOURCE`
   if [ -n "$PSTEXS" ]
   then
      echo "$PSTEXS"
   else
      echo "None."
   fi

   ### Save the filename so we can delete it later.
   TMPFILES="$TMPFILES $TARGETFILE"

   ### Insert pdf conversation tags in tex file and write it to TARGETFILE
   echo
   echo $MYNAME: Generating temporary LaTeX document

   ${SEDEXE} -e "s/\([\]includegraphics\)\(\[[^]]*\]\)\?\({[^}]\+\.\)\(e\)*ps}/\1\2\3pdf}/g" \
   -e "s/\([\]input{[^}]\+\.\)pstex_t}/\1pdf_t}/g" \
   -e "s/\([\]include{[^}]\+\)}/\1${TMPBASESUFFIX}}/g" \
   -e "1,/^[\]begin{document}$/s/^[\]batchmode$//" \
   -e "$INSERTCOMMAND"' \
   \\usepackage{pslatex}' \
   -e "$INSERTCOMMAND"' \
   \\makeatletter' \
   -e "$INSERTCOMMAND"' \
   \\usepackage[pdftex,pdftitle={'"$TITLE},pdfauthor={$AUTHOR},linktocpage,$PAPERSIZE,colorlinks={$COLORLINKS},urlcolor={$URLCOLOR},citecolor={$CITECOLOR}]{hyperref}"  \
   -e "$INSERTCOMMAND"' \
   \\makeatother' \
   $1 > $TARGETFILE

   if [ "$THUMB" = "yes" ]
   then
      ${SEDEXE} -e "$INSERTCOMMAND"' \
      \\usepackage{thumbpdf}' $TARGETFILE > ${TARGETFILE}2
      rm $TARGETFILE
      mv ${TARGETFILE}2 $TARGETFILE
   fi
      
   ### Convert all EPS images to pdf
   [ -n "$EPSIMAGES" ] && convert_eps2pdf $EPSIMAGES
   
   ### Convert all PSTEX_T files to PDF_T
   [ -n "$PSTEXS" ] && convert_pstex2pdf $PSTEXS
   
   echo
   echo "Finished: ${TEXSOURCE}."
}

### run pdflatex
# parameter $1: LaTeX file without extension
# return value: 0 - no errors (no rerun); 1 - errors (rerun required) 

run_pdflatex() {
   local TEXFILE=$1
   local errors=0
   echo "Pdflatex is running. Please wait."
   echo
   pdflatex --interaction nonstopmode ${PDFTEXOPTS} ${TEXFILE} > $PDFLOGFILE
   echo "Pdflatex finished. Errors:"
   errors=`grep "! Emergency stop\|Error:\|LaTeX Warning:" $PDFLOGFILE | wc -l`
   if [ $errors -ne 0 ]
   then
      if [ -n "`grep '! Emergency stop' $PDFLOGFILE`" ]
      then
         cat $PDFLOGFILE
	 echo
	 echo "$MYNAME: Fatal error occured. I am lost."
	 clean_up
	 echo "Aborting ..."
	 exit 1
      fi
      grep "Error:\|LaTeX Warning:" $PDFLOGFILE
      echo
      echo "$MYNAME: See $PDFLOGFILE for details."
      return 1
   else
      echo "None."
      return 0
   fi
} 

#### run bibtex if BIBTEX=yes or a bibliography tag is found
# included tex files are not parsed for a bibliography
# parmeter $1: filename of the aux file without .aux suffix

handle_bibtex() {
   AUXFILE=$1
   echo
   if [ "$BIBTEX" = "yes" ]
   then
      BIBLIO=1
      echo "$MYNAME: BibTeX paramter set to 'yes'; running BibTeX."
   else
      echo "$MYNAME: Checking for BibTeX bibliography in document."
      BIBLIO=`grep "^[^%]*[\]bibliography{" ${AUXFILE}.tex | wc -l`
      if [ $BIBLIO -ne 0 ]
      then
         echo "Bibliography detected; running BibTeX."
      else
         echo "No bibliography detected."
      fi
   fi
   if [ $BIBLIO -ne 0 ]
   then
      if ! bibtex ${AUXFILE} > ${BIBTEXLOG}
      then
         BIBTEXERR=1
      else
         BIBTEXERR=`grep "error message" ${BIBTEXLOG} | wc -l`
      fi
      if [ $BIBTEXERR -ne 0 ]
      then
         echo
         echo "****************** BibTeX errors reported *******************"
         cat ${BIBTEXLOG}
         echo "*************************************************************"
         echo
         echo "$MYNAME: You can switch off BibTeX support by setting BIBTEX=no in the parameter section of $MYNAME."
      else
         echo "BibTeX finished without errors."
      fi
   fi
} 

#### run thumbpdf command to make thumbnails
# more informations: /usr/share/texmf/doc/pdftex/thumbpdf/readme.txt
# parameter $1: LaTeX file without extension

run_thumbpdf() {
   local TEXFILE=$1
   echo
   echo "$MYNAME: Creating thumbnails with 'thumbpdf'"
   echo 
   thumbpdf ${TEXFILE}
   mv thumbpdf.log $THUMBPDFLOG

   echo
   echo "$MYNAME: See $THUMBPDFLOG for details."
   echo
   echo "Cleaning up (thumbpdf) ..."
   echo
   rm thumb???.png
   rm thumbpdf.pdf
   TMPFILES="$TMPFILES thumbdta.tex"
}

################## Lift off !!!! (main part) ##################
MYNAME=`basename $0`
TMPBASE=
TMPFILES=

echo
echo "$MYNAME: Script starts (Release $MYRELEASE)"

##### Preparing the LOGDIR
if ! mkdir -p ${LOGDIR}
then
   echo
   echo "$MYNAME: Could not create log directory ($LOGDIR)."
   echo "Aborting ..."
   exit 1
fi   

if [ -n "$LOGFILES" -a -n "`ls ${LOGDIR}`" -a "$CLEANLOGS" = "yes" ]
then
   echo
   echo "Cleaning up directory for log files ($LOGDIR)."
   rm ${LOGDIR}*
else
   echo
   echo "All log files will be stored in ($LOGDIR)."
fi

##### check for required commands
if [ -n "$SEDEXE" ]
then
   if [ ! -x "$SEDEXE" ]
   then
      echo
      echo "$MYNAME: Specified sed executable not found (${SEDEXE})"
      echo "Using sed executable in your path."
      echo "Maybe it does not work. GNU sed v3.02 or higher is recommended." 
      SEDEXE=sed
   fi
else
   SEDEXE=sed
fi

if [ "$COMMANDCHECK" != "no" ]
then
   check_commands
fi

##### Check arguments
echo
echo "$MYNAME: Processing your argument(s)."
check_arguments $@

##### Getting document name and path
DOCUMENT="$1"
DOCNAME=`basename $DOCUMENT`
DOCPATH=`echo "$DOCUMENT" | ${SEDEXE} -e "s/^\(.*\)$DOCNAME/\1/"`

###### change working directory to document directory
if [ -n "$DOCPATH" ]
then
   cd $DOCPATH
fi

###### make DOCPATH an absolute path
DOCPATH=`pwd`/

###### Cut off suffix and do lyx or tex specific stuff
DOCBASE=`basename $DOCNAME .lyx`
if [ "$DOCBASE" != "$DOCNAME" ]
then
   ### DOCNAME has an extention .lyx => Lyx document
   # generate Latex document if required
   generate_tex_file ${DOCBASE}.lyx ${DOCBASE}.tex
else
   ### given file is a LaTeX file
   # cut off .tex extension if there is one
   DOCBASE=`basename $DOCNAME .tex`
   
   ###### check access to given LaTeX document
   check_file ${DOCBASE}.tex "Cannot read the specified LaTeX document!"
fi

PASSEDTEXDOC=${DOCPATH}${DOCBASE}.tex
TMPBASE=${DOCBASE}${TMPBASESUFFIX}

##### Get title and author from main LaTeX document
echo
echo $MYNAME: Parsing LaTeX file 
if [ -z "$TITLE" ]
then
   TITLE=`${SEDEXE} -n "s/^.*[\]title{\([^{}]*\)}.*$/\1/1p" $PASSEDTEXDOC`
   if [ -z "$TITLE" ]
   then
      echo
      echo "$MYNAME: WARNING: Could not identify the document's title correctly."
      echo "Title field will be empty."
      echo "Maybe you have used a LaTeX Tag inside the title which confuses me."
      echo "You can either set a title in the parameter section of $MYNAME or"
      echo "change the title of the LaTeX file."
   fi
fi

if [ -z "$AUTHOR" ]
then
   AUTHOR=`${SEDEXE} -n "s/^.*[\]author{\([^{}]*\)}.*$/\1/1p" $PASSEDTEXDOC`
   if [ -z "$AUTHOR" ]
   then
      echo
      echo "$MYNAME: WARNING: Could not identify the document's author correctly."
      echo "Author field will be empty."
      echo "Maybe you have used a LaTeX Tag inside the author's name which confuses me."
      echo "You can either set an author in the parameter section of $MYNAME or"
      echo "change the author of the LaTeX file."
   fi
fi

echo
echo "Document's title: $TITLE"
echo "Document's author: $AUTHOR"

###### change working directory to INPUTPATH if set
# When the files' path (images, included documents, etc.) in your document is
# relative to another directory than the PASSED document's directory.
# This is useful when the calling application (e.g. LyX) generates a temporary
# TeX file and calls the tex2pdf with it instead of the original file.
INPUTPATH=`sed -n "s|^[\]def[\]input@path{\+\([^{}]*\)}\+|\1|1p" $PASSEDTEXDOC`
[ -n "$INPUTPATH" ] && cd $INPUTPATH

##### Get the list of imported files from the tex file
FILES=
getFileList $PASSEDTEXDOC

# remove main file from list (needs special handling)
FILES=`echo $FILES | ${SEDEXE} -e "s|^ *$PASSEDTEXDOC||"`

if [ -n "$FILES" ]
then
   echo 
   echo "Found the following included TeX files:"
   for file in $FILES ; do
      echo ">>>>> $file"
   done
else
   echo 
   echo "Found no included TeX files."
fi

##### Generate adjusted tex files and convert all their images
# main file
prepare_document $PASSEDTEXDOC ${TMPBASE}.tex

# included files
if [ -n "$FILES" ]
then
   for file in $FILES ; do
      TMP_FILE=`echo $file | ${SEDEXE} -e "s/\.tex$//"`
      prepare_document $file ${TMP_FILE}${TMPBASESUFFIX}.tex
   done
fi

##### Generate the final PDF document
### run pdflatex until no more errors are reported (max MAXRUNNO) 
runno=1
rerun=1
while [ $rerun -ne 0 -a $runno -le $MAXRUNNO ]
do
   echo
   echo "************ Pdflatex run no. $runno *************"
   if run_pdflatex ${TMPBASE} && [ $MINRUNNO -le $runno ]
   then
      # no errors detected and MINRUNNO is processed
      rerun=0
   else
      # errors or MINRUNNO has not been reached
      rerun=1
   fi 
   
   ### Execute BibTeX after first run if set (and required)
   if [ $runno -eq 1 -a "$BIBTEX" != "no" ]
   then
      handle_bibtex ${TMPBASE}
   fi

   runno=$((runno+1))
done

rerun=0

### if the THUMB option is switched on then make thumbnails
if [ "$THUMB" = "yes" ]
then
   run_thumbpdf ${TMPBASE}
   rerun=1
fi

### generate index if required
if [ -f ${TMPBASE}.idx  -a "$MAKEINDEX" != "no" ]
then
   echo
   echo "$MYNAME: Document seems to have an index. Generating ..."
   echo
   makeindex ${TMPBASE}.idx
   rerun=1
fi

### One final pdflatex run if requested
if [ $rerun -ne 0 ]
then
   echo
   echo "************ One final pdflatex run no. $runno *************"
   run_pdflatex ${TMPBASE}
fi

##### Clean up
if [ -f ${TMPBASE}.pdf ]
then
   mv ${TMPBASE}.pdf ${PDFOUTDIR}${DOCBASE}.pdf
else
   echo
   echo "$MYNAME: The PDF file ${TMPBASE}.pdf was not generated."
   clean_up
   echo "Aborting ..."
   exit 1
fi

echo
clean_up

echo
echo "The new pdf file is: ${PDFOUTDIR}${DOCBASE}.pdf"
echo

