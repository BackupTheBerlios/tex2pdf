#!/bin/bash

#      lyx2pdf - script for translating lyx docs to pdf
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
# Version History:
#
# Aug 13th, 2000 -- Version 1.2
#  * initial public version
#     (thanks to Matej Cepl helping me with the pdflatex stuff)
#     (thanks to Herbert Voss for helping me with the latex stuff)
#     (thanks to all the people who supported me with their feedback)
#
# Aug 14th, 2000 -- Version 1.3
#  * added command to rename ~/.lyx/lyxpipe.out and ~/.lyx/lyxpipe.in 
#     (thanks to Herbert Voss for this hint)
#  * converted the sed command to be suitable for a single line
#  * added check for number of command line arguments
#
# Sep 15th, 2000 -- Version 1.4
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
# Sep 20th, 2000 -- Version 1.5
#  * made command checking work on more systems and give advice
#  * stopped pdflatex to prompt for input (output redirection=> invisible!)
#  * some more status messages for pdflatex
#  * minor changes
#
# Oct 14th, 2000 -- Version 1.6
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
# Oct 15th, 2000 -- Version 1.7
#  * fixed checkCommand function - buggy output redirection generated file '1'
#     (thanks to Nicolas Marsgui for this patch)
#
# Oct 20th, 2000 -- Version 1.8 beta 1
#  * fixed permission problems with multiple users (log-files)
#     (thanks to Garrick Chien Welsh for this patch)
#
# Jan 14th, 2001 -- Version 1.8 beta 2 
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
# Jan 21th, 2001 -- Version 1.8 beta 3 
#  * modified LyX export command to work with LyX 1.1.6
#     (thanks to Stacy J. Prowell <sprowell@cs.utk.edu> for this hint)
#
# Mar 02nd, 2001 -- Version 1.8 beta 4 
#  * modified image searching to cover not only first image in a line
#     (thanks to Holger Daszler for this hint)
#
# Mar 09nd, 2001 -- Version 1.8 
#  * included convert_pstex2pdf tmp files in clean up
#  * added support for PDF thumbnails
#     (thanks to Olaf Gabler for his patch)
#  * better code structure (more functions)
#  * minor changes
#

MYVERSION="1.8"

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
# no value means the same directory as the lyx file
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

# log file for the output of pdflatex, bibtex and thumbpdf
PDFLOGFILE=/tmp/pdflatex-$USER-$$.log
BIBTEXLOG=/tmp/bibtex-$USER-$$.log
THUMBPDFLOG=/tmp/thumbpdf-$USER-$$.log

# additional options for pdflatex
PDFTEXOPTS=""

# Use which command to check executables
WHICHON="yes"

# use thumbpdf to include thumbnails of all PDF document pages
# requires ghostscript version 5.50 or higher to generate the thumbnails (PNG)
# see more informations: /usr/share/texmf/doc/pdftex/thumbpdf/readme.txt
# possible values: "yes" for thumbnails, "no" - without thumbnails
THUMB="no"

##### Functions

### Removing all temporary files
clean_up() {
   echo $MYNAME: Removing temporary files ... 
   [ -n "$TMPFILES" ] && rm $TMPFILES
   rm ${TMPBASE}.*
}

### Check for required command with 'which' 
checkCommand(){
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
         echo $MYNAME: "$2"
      fi
      echo "$MYNAME: Aborting ..."
      exit 1
   fi
}

### Build a list of all files which are included from the root file.
### This function recurses, and is maybe smart enough to detect cycles.
# One input parameter for this ($1): a tex file.
# Be sure to set FILES to the empty string prior to calling this.

getFileList() {
   # This is the cycle avoidance logic.
   flag=`echo $FILES | ${SEDEXE} -n "/\W$1\W/p"`
   if [ -z "$flag" ] ; then
      # Save the argument in the list of files.
      FILES="$FILES $1"
      # Get the list of files included by the argument.
      local IMPORTS=`${SEDEXE} -n "s/^.*[\]include{\([^}]\+\)}.*$/\1.tex /p" $1`
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
   echo
   for image in $IMAGES
   do
      IMAGENAME=`basename $image`
      IMAGEPATH=`echo "$image" | ${SEDEXE} -n "s/^\(.*\)$IMAGENAME$/\1/p"`
      IMAGEBASE=`basename $IMAGENAME .eps`
      IMAGEBASE=`basename $IMAGEBASE .ps`

      #### check if image file really exists
      if [ ! -f ${IMAGEPATH}${IMAGENAME} ]
      then
         echo
         echo "$MYNAME: Could not find the image ${IMAGEPATH}${IMAGENAME} "
	 clean_up
         echo "$MYNAME: Aborting ..."
         echo
         exit 1
      fi
   
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
   echo
   for pstexfile in $PSTEXS
   do
      PSTEXNAME=`basename $pstexfile`
      PSTEXPATH=`echo "$pstexfile" | ${SEDEXE} -n "s/^\(.*\)$PSTEXNAME$/\1/p"`
      PSTEXBASE=`basename $PSTEXNAME .pstex_t`

      #### check if image file really exists
      if [ ! -f ${PSTEXPATH}${PSTEXNAME} ]
      then
         echo
         echo "$MYNAME: Could not find the image ${PSTEXPATH}${PSTEXNAME} "
	 clean_up
         echo "$MYNAME: Aborting ..."
         echo
         exit 1
      fi
   
      # descend into file
      echo Converting file ${PSTEXNAME} ...

      # create .pdf_t file
      sed -e "s/\(^[^%]*[\]includegraphics{.*\.\)pstex\(.*$\)/\1pdf\2/g" ${PSTEXPATH}${PSTEXNAME} > "${PSTEXPATH}${PSTEXBASE}.pdf_t"
      
      # find included EPS image
      EPSIMAGE=`${SEDEXE} -n "s/^[^%]*[\]includegraphics{\([^}]\+\)}.*$/\1/pg" ${PSTEXPATH}${PSTEXNAME}`
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

imagePDFify() {
  
   ### set required variables 
   TEXSOURCE=$1
   SOURCEBASE=`basename $TEXSOURCE .tex`
   SOURCEPATH=`echo $TEXSOURCE | ${SEDEXE} -e "s/^\(.*\)$SOURCEBASE\.tex/\1/"`
   TARGETNAME=${SOURCEBASE}-pdf.tex
   TARGETFILE="${SOURCEPATH}${SOURCEBASE}-pdf.tex"

   ### Save the filename so we can delete it later.
   TMPFILES="$TMPFILES $TARGETFILE"

   ##### Get EPS images from the source file
   EPSIMAGES=`${SEDEXE} -n "s/^[^%]*[\]includegraphics{\([^}]\+\.\(e\)*ps\)}.*$/\1 /pg" $TEXSOURCE`
   echo "Identified EPS images (.eps/.ps): $EPSIMAGES"
   
   ##### Get PSTEX_T files from the source file
   PSTEXS=`${SEDEXE} -n "s/^[^%]*[\]input{\([^}]\+\.pstex_t\)}.*$/\1 /p" $TEXSOURCE`
   echo "Identified PSTEX_T files (.pstex_t): $PSTEXS"

   ### Insert pdf conversation tags in tex file and write it to TARGETFILE
   echo
   echo $MYNAME: Preparing LaTeX document for translation to pdf

   ${SEDEXE} -e "s/\([\]includegraphics{[^}]\+\.\)\(e\)*ps}/\1pdf}/g" \
   -e "s/\([\]input{[^}]\+\.\)pstex_t}/\1pdf_t}/g" \
   -e 's/\([\]include{[^}]\+\)}/\1-pdf}/g' \
   -e '/^\\makeatletter$/i \
   \\usepackage{pslatex}' \
   -e '/^\\makeatletter$/i \
   \\usepackage[pdftex,pdftitle={'"$TITLE},pdfauthor={$AUTHOR},linktocpage,$PAPERSIZE,colorlinks={$COLORLINKS},urlcolor={$URLCOLOR},citecolor={$CITECOLOR}]{hyperref}"  \
   $1 > $TARGETFILE

   if [ "$THUMB" = "yes" ]
   then
      ${SEDEXE} -e '/^\\makeatletter$/i \
      \\usepackage{thumbpdf}' $TARGETFILE > ${TARGETFILE}2
      rm $TARGETFILE
      mv ${TARGETFILE}2 $TARGETFILE
   fi
      
   ### Convert all EPS images to pdf
   [ -n "$EPSIMAGES" ] && convert_eps2pdf $EPSIMAGES
   
   ### Convert all PSTEX_T files to PDF_T
   [ -n "$PSTEXS" ] && convert_pstex2pdf $PSTEXS
}

run_pdflatex() {
   echo "Pdflatex is running. Please wait."
   echo
   pdflatex --interaction nonstopmode ${PDFTEXOPTS} ${TMPBASE} > $PDFLOGFILE
   echo "Pdflatex finished. Errors:"
   rerun=`grep "! Emergency stop\|Error:\|LaTeX Warning:" $PDFLOGFILE | wc -l`
   if [ $rerun -ne 0 ]
   then
      if [ -n "`grep '! Emergency stop' $PDFLOGFILE`" ]
      then
         cat $PDFLOGFILE
	 echo
	 echo "$MYNAME: Fatal error occured. I am lost."
	 clean_up
	 echo "$MYNAME: Aborting ..."
	 exit 1
      fi
      grep "Error:\|LaTeX Warning:" $PDFLOGFILE
      echo
      echo "$MYNAME: See $PDFLOGFILE for details."
   else
      echo "None."
   fi
} 

#### run bibtex if BIBTEX=yes or a bibliography tag is found
# included tex files are not parsed (would that be useful?)

handle_bibtex() {
   echo
   if [ "$BIBTEX" = "yes" ]
   then
      BIBLIO=1
      echo "$MYNAME: BibTeX paramter set to 'yes'; running BibTeX."
   else
      echo "$MYNAME: Checking for BibTeX bibliography in document."
      BIBLIO=`grep "[\]bibliography{" ${TMPBASE}.tex | wc -l`
      if [ $BIBLIO -ne 0 ]
      then
         echo "Bibliography detected; running BibTeX."
      else
         echo "No bibliography detected."
      fi
   fi
   if [ $BIBLIO -ne 0 ]
   then
      if ! bibtex ${TMPBASE} > ${BIBTEXLOG}
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

run_thumbpdf() {
   echo
   echo "$MYNAME: Creating thumbnails with 'thumbpdf'"
   echo 
   thumbpdf ${TMPBASE}
   mv thumbpdf.log $THUMBPDFLOG

   echo
   echo "$MYNAME: See $THUMBPDFLOG for details."
   echo
   echo "$MYNAME: Cleaning up (thumbpdf) ..."
   echo
   rm thumb???.png
   rm thumbpdf.pdf

   echo
   echo "************ One final pdflatex run no. $runno *************"
   run_pdflatex
   rm thumbdta.tex
}

##### Lift off
MYNAME=`basename $0`

echo
echo "$MYNAME: Script starts (Version $MYVERSION)"

##### set the sed executable
# GNU sed version 3.02 or higher is recommended

if [ -n "$SEDEXE" -a ! -x "$SEDEXE" ]
then
   echo
   echo "$MYNAME: Specified sed executable not found (${SEDEXE})"
   echo "Using sed executable in your path."
   echo "Maybe it does not work. GNU sed v3.02 or higher is recommended." 
   SEDEXE=
fi

if [ "$WHICHON" = "yes" ] 
then
   checkCommand pdflatex "See pdftex homepage for details: http://tug.org/applications/pdftex"
   checkCommand epstopdf "See pdftex homepage for details: http://tug.org/applications/pdftex"
   if [ -z "$SEDEXE" ]
   then
      checkCommand sed "You should get GNU sed 3.02 or later: ftp://ftp.gnu.org/pub/gnu/sed"
      SEDEXE=sed
   fi
   if [ "$BIBTEX" != "no" ]
   then
      checkCommand bibtex "You can switch off BibTeX support by setting BIBTEX=no in the parameter section of $MYNAME."
   fi
fi

##### Check arguments
if [ $# -ne 1 ]
then
   echo
   echo $MYNAME: Wrong number of arguments.
   echo
   echo Usage: $MYNAME DOCUMENT.lyx
   echo
   exit 1
fi

###### set environment variables
echo
echo $MYNAME: Setting environment variables
LYXDOC=$1
DOCUMENTBASE=`basename $LYXDOC .lyx`
DOCPATH=`echo $LYXDOC | ${SEDEXE} -e "s/^\(.*\)$DOCUMENTBASE\.lyx/\1/"`
TEXDOC=${DOCUMENTBASE}.tex
TMPBASE=${DOCUMENTBASE}-pdf
TMPFILES=

###### change working directory to document directory
if [ -n "$DOCPATH" ]
then
   cd $DOCPATH
fi

##### some variables not used ...
#VERSION=`rlog ${DOCPATH}$DOCUMENTBASE.lyx,v | ${SEDEXE} -n "s/^head: \([[:digit:].]*\)$/\1/1p"`
#TRANSTIME=`date`

##### Make sure that everything is alright with the LyX and TeX file 
if [ ! -f "$LYXDOC" ]
then
   echo
   echo "$MYNAME: Sorry. I cannot find '$LYXDOC'."
   echo "$MYNAME: The specified LyX document does not exist!"
   echo "$MYNAME: Aborting ..."
   echo
   exit 1
fi

if [ -f "$TEXDOC" -a "$TEXDOC" -nt "$LYXDOC" ]
then
   echo
   echo "$MYNAME: TeX file is newer than LyX document '$LYXDOC'."
   echo "$MYNAME: Using existing TeX file: $TEXDOC"
   echo "$MYNAME: Remove it to force its new generation."
   echo 
else
   ### export TEX file with lyx (needs a display!)
   echo
   echo $MYNAME: Exporting latex file 
   [ -f $HOME/.lyx/lyxpipe.out ] && mv $HOME/.lyx/lyxpipe.out $HOME/.lyx/lyxpipe.out~
   [ -f $HOME/.lyx/lyxpipe.in ] && mv $HOME/.lyx/lyxpipe.in $HOME/.lyx/lyxpipe.in~
   [ -f $TEXDOC ] && mv $TEXDOC $TEXDOC~
   lyx --export latex ${DOCUMENTBASE}.lyx
   
   ### check if tex file now really exists
   if [ ! -f $TEXDOC ]
   then
      echo
      echo "$MYNAME: The LaTeX document was not generated by LyX!"
      echo "$MYNAME: Aborting ..."
      echo
      exit 1
   fi
fi

##### Get title and author from the produced parent tex file
echo
echo $MYNAME: Parsing latex file 
if [ -z "$TITLE" ]
then
   TITLE=`${SEDEXE} -n "s/^[\]title{\(.*\)}.*$/\1/1p" $TEXDOC`
fi

if [ -z "$AUTHOR" ]
then
   AUTHOR=`${SEDEXE} -n "s/^[\]author{\(.*\)}.*$/\1/1p" $TEXDOC`
fi

echo
echo Document title: $TITLE
echo Document author: $AUTHOR

##### Get the list of imported files from the tex file.
getFileList $TEXDOC
echo 
echo "Found the following included TeX files:"
for file in $FILES ; do
   echo ">>>>> $file"
done

##### Convert all refered images
for file in $FILES ; do
   echo
   echo "Converting images in $file."
   imagePDFify $file
   echo "Finished: $file"
done

##### Generate the final PDF document
### run pdflatex until no more errors are reported (max MAXRUNNO) 
runno=1
rerun=1
while [ $rerun -ne 0 -a $runno -le $MAXRUNNO ]
do
   echo
   echo "************ Pdflatex run no. $runno *************"
   run_pdflatex
   
   ### Execute BibTeX after first run if set (and required)
   if [ $runno -eq 1 -a "$BIBTEX" != "no" ]
   then
      handle_bibtex
   fi

   runno=$((runno+1))
done

### if the THUMB option is switched on then make thumbnails
if [ "$THUMB" = "yes" ]
then
   run_thumbpdf
fi

##### Clean up
if [ -f ${TMPBASE}.pdf ]
then
   mv ${TMPBASE}.pdf ${PDFOUTDIR}${DOCUMENTBASE}.pdf
else
   echo
   echo "$MYNAME: The PDF file ${TMPBASE}.pdf was not generated."
   clean_up
   echo "$MYNAME: Aborting ..."
   exit 1
fi

echo
clean_up

echo
echo "The new pdf file is: ${PDFOUTDIR}${DOCUMENTBASE}.pdf"
echo

