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

MYVERSION="1.6"

##### You will need pdftex and epstopdf for the generation!
##### See pdftex homepage for details: http://tug.org/applications/pdftex/
##### Have fun!!!

##### Parameters: Adjust them to your personal system

### pdftex package options: 
### see hyperref manual for more:/usr/share/texmf/doc/latex/hyperref/manual.pd

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
# leave blank for LaTex document title
TITLE=

# Author info for resulting document
# leave blank for LaTex document author
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

# log file for the output of pdflatex and bibtex
PDFLOGFILE=/tmp/pdflatex.log
BIBTEXLOG=/tmp/bibtex.log

# additional options for pdflatex
PDFTEXOPTS=""

# Use which command to check executables
WHICHON="yes"

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

##### Check other dependencies with which if turned on
checkCommand(){
   WHICHRESULT=`which $1 2>1`
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

###### change working directory to document directory
if [ -n "$DOCPATH" ]
then
   cd $DOCPATH
fi

##### some variables not used ...
#VERSION=`rlog ${DOCPATH}$DOCUMENTBASE.lyx,v | ${SEDEXE} -n "s/^head: \([[:digit:].]*\)$/\1/1p"`
#TRANSTIME=`date`

##### export TEX file with lyx (needs a display!)
echo
echo $MYNAME: Exporting latex file 
[ -f $HOME/.lyx/lyxpipe.out ] && mv $HOME/.lyx/lyxpipe.out $HOME/.lyx/lyxpipe.out~
[ -f $HOME/.lyx/lyxpipe.in ] && mv $HOME/.lyx/lyxpipe.in $HOME/.lyx/lyxpipe.in~
[ -f $TEXDOC ] && mv $TEXDOC $TEXDOC~
lyx --export tex ${DOCUMENTBASE}.lyx

##### check if tex file now really exists
if [ ! -f $TEXDOC ]
then
   echo
   echo "$MYNAME: The LaTeX document was not generated by LyX!"
   echo "$MYNAME: Aborting ..."
   echo
   exit 1
fi

##### get title, author and images from the produced tex file
echo
echo $MYNAME: Parsing latex file 
if [ -z "$TITLE" ]
then
   TITLE=`${SEDEXE} -n "s/^.title{\(.*\)}.*$/\1/1p" $TEXDOC`
fi

if [ -z "$AUTHOR" ]
then
   AUTHOR=`${SEDEXE} -n "s/^.author{\(.*\)}.*$/\1/1p" $TEXDOC`
fi

IMAGES=`${SEDEXE} -n "s/^.*includegraphics{\([^}]\+\.\(e\)*ps\)}.*$/\1 /p" $TEXDOC`

echo
echo Document title: $TITLE
echo Document author: $AUTHOR
echo "Identified images (.eps/.ps):" $IMAGES

####### Insert pdf conversation tags in tex file and write to foo-pdf.tex
### some possible colors: red, green, cyan, blue, magenta, black
### see hyperref manual for more:/usr/share/texmf/doc/latex/hyperref/manual.pdf
echo
echo $MYNAME: Preparing LaTex document for translation to pdf

${SEDEXE} -e "s/\(\\includegraphics{[^}]\+\.\)\(e\)*ps}/\1pdf}/g" \
-e '/^\\makeatletter$/i \
\\usepackage{pslatex}' \
-e '/^\\makeatletter$/i \
\\usepackage[pdftex,pdftitle={'"$TITLE},pdfauthor={$AUTHOR},linktocpage,$PAPERSIZE,colorlinks={$COLORLINKS},urlcolor={$URLCOLOR},citecolor={$CITECOLOR}]{hyperref}"  \
$TEXDOC > $TMPBASE.tex

####### Convert eps images to pdf
echo
echo $MYNAME: Converting images from eps to pdf
echo
PDFIMAGES=
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
      echo "$MYNAME: Aborting ..."
      echo
      exit 1
   fi
   
   echo Converting image ${IMAGENAME} to pdf
   epstopdf -outfile=${IMAGEPATH}${IMAGEBASE}.pdf ${IMAGEPATH}${IMAGENAME}
   PDFIMAGES="$PDFIMAGES ${IMAGEPATH}${IMAGEBASE}.pdf"
done

######## Run pdflatex as many times as needed
runno=1
rerun=1
while [ $rerun -ne 0 -a $runno -le $MAXRUNNO ]
do
   echo
   echo "************ Pdflatex run no. $runno *************"
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
	 echo "$MYNAME: Aborting ..."
	 exit 1
      fi
      grep "Error:\|LaTeX Warning:" $PDFLOGFILE
      echo
      echo "$MYNAME: See $PDFLOGFILE for details."
   else
      echo "None."
   fi
   
   ##### Check for BibTeX references after first run
   if [ $runno -eq 1 -a "$BIBTEX" != "no" ]
   then
      if [ "$BIBTEX" = "yes" ]
      then
	 BIBLIO=1
         echo "$MYNAME: BibTeX paramter set to 'yes'; running BibTeX."
      else
         echo
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
      echo
   fi

   runno=$((runno+1))
done

### Clean up
if [ -f ${TMPBASE}.pdf ]
then
   mv ${TMPBASE}.pdf ${PDFOUTDIR}${DOCUMENTBASE}.pdf
else
   echo
   echo "$MYNAME: The PDF file ${TMPBASE}.pdf was not generated."
   echo $MYNAME: Cleaning up
   rm ${TMPBASE}.* $PDFIMAGES
   echo "$MYNAME: Aborting ..."
   exit 1
fi

echo
echo $MYNAME: Cleaning up
rm ${TMPBASE}.* $PDFIMAGES

echo
echo "The new pdf file is: ${PDFOUTDIR}${DOCUMENTBASE}.pdf"
echo

