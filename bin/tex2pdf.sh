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
#
# Version History:
#
# Aug 13th, 2000 -- Version 1.2
#   initial version
#
# Aug 14th, 2000 -- Version 1.3
#  * added command to rename ~/.lyx/lyxpipe.out and ~/.lyx/lyxpipe.in 
#    (thanks to Herbert Voss for this hint)
#  * converted the sed command to be suitable for a single line
#  * added check for number of command line arguments
#

##### You will need pdftex and epstopdf for the translation!
##### See pdftex homepage for details: http://tug.org/applications/pdftex/
##### Have fun!!!


##### Check arguments
MYNAME=`basename $0`
echo
##### Check arguments
if [ $# -ne 1 ]
   echo
   echo $MYNAME: Wrong number of arguments.
   echo
   echo Usage: $MYNAME DOCUMENT.lyx
   echo
   exit 1
fi

echo $MYNAME: Setting environment variables
LYXDOC=$1
LYXPATH=`echo $LYXDOC | sed -e "s/^\(.*\)$DOCUMENTBASE\.lyx/\1/"`
LYXPATH=`echo $LYXDOC | ${SEDEXE} -e "s/^\(.*\)$DOCUMENTBASE\.lyx/\1/"`
TEXDOC=${LYXPATH}${DOCUMENTBASE}.tex
##### some variables not usedi ...
#VERSION=`rlog ${LYXPATH}$DOCUMENTBASE.lyx,v | sed -n "s/^head: \([[:digit:].]*\)$/\1/1p"`
#VERSION=`rlog ${LYXPATH}$DOCUMENTBASE.lyx,v | ${SEDEXE} -n "s/^head: \([[:digit:].]*\)$/\1/1p"`
#TRANSTIME=`date`

mv $HOME/.lyx/lyxpipe.out $HOME/.lyx/lyxpipe.out~
mv $HOME/.lyx/lyxpipe.in $HOME/.lyx/lyxpipe.in~
mv $TEXDOC $TEXDOC~
[ -f $TEXDOC ] && mv $TEXDOC $TEXDOC~
lyx --export tex $1

TITLE=`sed -n "s/^.title{\(.*\)}.*$/\1/1p" $TEXDOC`
AUTHOR=`sed -n "s/^.author{\(.*\)}.*$/\1/1p" $TEXDOC`
IMAGES=`sed -n "s/^.*includegraphics{\([^}]\+\.\(e\)*ps\)}.*$/\1 /p" $TEXDOC`
IMAGES=`${SEDEXE} -n "s/^.*includegraphics{\([^}]\+\.\(e\)*ps\)}.*$/\1 /p" $TEXDOC`

echo
echo Document title: $TITLE
echo Document author: $AUTHOR
echo
echo "Identified images (.eps/.ps):" $IMAGES

### some possible colors:red, green, cyan, blue, magenta, black
### some possible paper sizes: a4paper, letterpaper, legalpaper, executivepaper
### some possible colors: red, green, cyan, blue, magenta, black
sed -e "s/\(\\includegraphics{[^}]\+\.\)\(e\)*ps}/\1pdf}/g" -e '/^\\makeatother$/i \\usepackage{pslatex}' -e '/^\\makeatother$/i \\usepackage[pdftex,pdftitle={'"$TITLE}, pdfauthor={$AUTHOR},linktocpage,a4paper,colorlinks=true,urlcolor=blue,citecolor=magenta]{hyperref}" $TEXDOC > ${LYXPATH}${DOCUMENTBASE}-pdf.tex
$TEXDOC > ${LYXPATH}${DOCUMENTBASE}-pdf.tex

echo
PDFIMAGES=
for image in $IMAGES
 IMAGENAME=`basename $image`
 IMAGEPATH=`echo "$image" | sed -n "s/^\(.*\)$IMAGENAME$/\1/p"`
 IMAGEBASE=`basename $IMAGENAME .eps`
 IMAGEBASE=`basename $IMAGEBASE .ps`
   #### determine image path
   if [ `echo $image | cut -c 1` != "/" ]
   then
      # relative pathname
      IMAGEPATH=${LYXPATH}$IMAGEPATH
   
   echo Converting image ${IMAGENAME} to pdf
   epstopdf -outfile=${IMAGEPATH}${IMAGEBASE}.pdf ${IMAGEPATH}${IMAGENAME}
   PDFIMAGES="$PDFIMAGES ${IMAGEPATH}${IMAGEBASE}.pdf"
done
######## Run pdflatex 9 times
for runno in 1 2 3 4 5 6 7 8 9
while [ $rerun -ne 0 -a $runno -le $MAXRUNNO ]
do
   echo
   echo "************ PDF Latex run no. $runno *************"
   pdflatex ${LYXPATH}${DOCUMENTBASE}-pdf.tex 
   runno=$((runno+1))
done

echo $MYNAME: Cleaning up
mv ${LYXPATH}${DOCUMENTBASE}-pdf.pdf ${LYXPATH}${DOCUMENTBASE}.pdf
rm ${LYXPATH}${DOCUMENTBASE}-pdf.* $PDFIMAGES

echo
echo "The new pdf file is: ${LYXPATH}${DOCUMENTBASE}.pdf"
echo

