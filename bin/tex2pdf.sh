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
# Credits:
# Thanks to Matej Cepl and Herbert Voss for helping me with the latex stuff!
# Thanks to all the people who supported me with their feedback!
# 
# Version History:
#
# Aug 13th, 2000 -- Version 1.2
#   initial version
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

##### You will need pdftex and epstopdf for the translation!
##### See pdftex homepage for details: http://tug.org/applications/pdftex/
##### Have fun!!!

##### Parameters: Adjust them to your personal system
# papersize of the resulting pdf document
# some possible values: a4paper, letterpaper, legalpaper, executivepaper
PAPERSIZE=a4paper

# sed executable this script should use
SEDEXE=/usr/bin/sed

# maximal number of runs for pdflatex
MAXRUNNO=9

# log file for the output of pdflatex
PDFLOGFILE=/tmp/latex2pdf.log

# additional options for pdflatex
PDFTEXOPTS=""

# Use which command to check executables
WHICHON=yes

##### Lift off
MYNAME=`basename $0`

echo
echo $MYNAME: Script starts

##### set the sed executable
# GNU sed version 3.02 or higher is recommended

if [ ! -x ${SEDEXE} ]
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
LYXPATH=`echo $LYXDOC | ${SEDEXE} -e "s/^\(.*\)$DOCUMENTBASE\.lyx/\1/"`
TEXDOC=${LYXPATH}${DOCUMENTBASE}.tex

##### some variables not used ...
#VERSION=`rlog ${LYXPATH}$DOCUMENTBASE.lyx,v | ${SEDEXE} -n "s/^head: \([[:digit:].]*\)$/\1/1p"`
#TRANSTIME=`date`

##### export TEX file with lyx (needs a display!)
echo
echo $MYNAME: Exporting latex file 
[ -f $HOME/.lyx/lyxpipe.out ] && mv $HOME/.lyx/lyxpipe.out $HOME/.lyx/lyxpipe.out~
[ -f $HOME/.lyx/lyxpipe.in ] && mv $HOME/.lyx/lyxpipe.in $HOME/.lyx/lyxpipe.in~
[ -f $TEXDOC ] && mv $TEXDOC $TEXDOC~
lyx --export tex $1

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
TITLE=`${SEDEXE} -n "s/^.title{\(.*\)}.*$/\1/1p" $TEXDOC`
AUTHOR=`${SEDEXE} -n "s/^.author{\(.*\)}.*$/\1/1p" $TEXDOC`
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
-e '/^\\makeatother$/i \
\\usepackage{pslatex}' \
-e '/^\\makeatother$/i \
\\usepackage[pdftex,pdftitle={'"$TITLE},pdfauthor={$AUTHOR},linktocpage,$PAPERSIZE,colorlinks=true,urlcolor=blue,citecolor=magenta]{hyperref}"  \
$TEXDOC > ${LYXPATH}${DOCUMENTBASE}-pdf.tex

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

   #### determine image path
   if [ `echo $image | cut -c 1` != "/" ]
   then
      # relative pathname
      IMAGEPATH=${LYXPATH}$IMAGEPATH
   fi

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
   pdflatex --interaction nonstopmode ${PDFTEXOPTS} ${LYXPATH}${DOCUMENTBASE}-pdf.tex > $PDFLOGFILE
   echo "Pdflatex finished. Errors:"
   rerun=`grep "Error:\|LaTeX Warning:" $PDFLOGFILE | wc -l`
   if [ $rerun -ne 0 ]
   then
      grep "Error:\|LaTeX Warning:" $PDFLOGFILE
   else
      echo "None."
   fi
   runno=$((runno+1))
done

### Clean up
echo
echo $MYNAME: Cleaning up
mv ${LYXPATH}${DOCUMENTBASE}-pdf.pdf ${LYXPATH}${DOCUMENTBASE}.pdf
rm ${LYXPATH}${DOCUMENTBASE}-pdf.* $PDFIMAGES

echo
echo "The new pdf file is: ${LYXPATH}${DOCUMENTBASE}.pdf"
echo

