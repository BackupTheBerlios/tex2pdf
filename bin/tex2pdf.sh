#!/bin/bash

#      tex2pdf - script for translating latex docs to pdf
#
#      Copyright (C) 2000,2001 by Steffen Evers (tron@cs.tu-berlin.de)
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
# ?????????????? -- Release 2.2
#  * made the script a little bit safer (log files, temp files, parameters)
#  * introduced experimental support for private configuration files and
#    command line options (set USE_EXTENDED_OPTIONS=yes to activate)
#     (thanks to Steffen Macke for this great patch)
#

MYRELEASE="2.1.3"

##### You will need pdftex and epstopdf for the generation!
##### See pdftex homepage for details: http://tug.org/applications/pdftex/
##### Have fun!!!

##### Default parameters
## Change the parameters below if you want to change the default settings for
## all users.  If you only want to change your private parameters change them
## in the RC_FILE (experimental - see below)

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
MINRUNNO=2

# directory for log files
LOGDIR=/tmp/tex2pdf-$USER/

# clean log files before execution
# You might get problems with this when you run tex2pdf on several documents
# at the same time. So, if you want to be on the safe side set "no" and clean
# the log directory manually.
# possible values: 'yes', 'no'
CLEANLOGS="no"

# Use which command to check for required executables
# possible values: 'yes', 'no'
COMMANDCHECK="yes"

# use thumbpdf to include thumbnails of all PDF document pages
# requires ghostscript version 5.50 or higher to generate the thumbnails (PNG)
# see more informations: /usr/share/texmf/doc/pdftex/thumbpdf/readme.txt
# possible values: "yes" for thumbnails, "no" - without thumbnails
THUMB="no"

# execution of the makeindex command for index handling
# this should fix the problem with a missing document index
# possible values: "yes" - check for index file and if found call makeindex
#                  "no"  - never execute it
MAKEINDEX="yes"

##### expert parameters
## the following parameters should NOT be modified by regular users!
## study the script carefully before you change them !!!

# additional options for pdflatex
PDFTEXOPTS=""

# suffix for tmp files that will be put in between the basename and suffix of
# the original file
# CAUTION: If you leave this blank you will overwrite the original files!
TMPBASESUFFIX=-pdf

# sed command which is used to insert additional TeX commands in the LaTeX
# preamble
# try the following commands if you have strange errors or junk on the
# first PDF document page
# INSERTCOMMAND="/^[\]begin{document}$/i"
# INSERTCOMMAND="/^[\]makeatletter$/i"
INSERTCOMMAND="/^[\]documentclass\(\[[^]]*\]\)\?{.*}/a"

# use private configuration files (RC_FILES) and command line options
# This is experimental at the moment and should not be used for regular work
# Be careful with it!
# possible values: "yes" - use RCS_FILES and command line options,
#                  "no"  - do not use this feature
USE_EXTENDED_OPTIONS=no

### file to store private parameters
# If you only want to change your private parameters change them there
# default: $HOME/.tex2pdfrc
RC_FILE=$HOME/.tex2pdfrc

# print the configuration parameters and exit
# used for debugging USE_EXTENDED_OPTIONS (see above)
# possible values: "yes" - print and exit, "no" - regular execution
PRINT_ONLY=no

##### Functions ###########################################

#### General functions (not script specific)

###  exit with an error message

abort() {
   echo $MYNAME: "$@"
   echo Aborting ...
   exit 1
}

### interactively answer a question with yes or no
# $1 question
# $2 default value

questionYN() {
   local response
   local default
   while true; do
      if [ $2 = yes ]
      then
         echo -n "$1" "[y]"
         default=yes
      else
         echo -n "$1" "[n]"
         default=no
      fi
      read response </dev/tty
      case $response in
         y*|Y*) RESPONSE=yes; return ;;
         n*|N*) RESPONSE=no; return ;;
         "") RESPONSE=$default; return ;;
         *) echo Please respond with y or n.
      esac
   done
}

### interactively answer a question
# $1 question

question() {
   echo -n "$1 "
   read RESPONSE </dev/tty
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

#### Specific functions (for use with this script only)

### print usage of command

usage () {
   echo
   echo "Usage: $MYNAME [OPTIONS] DOCUMENT.lyx"
   echo "       $MYNAME [OPTIONS] DOCUMENT.tex"
   echo "       $MYNAME [-h|-v|-p|-c]"
   echo
}

### print command help

help () {
   echo
   echo "$MYNAME  Version $MYRELEASE"
   usage
   echo "     -i : force makeindex"
   echo "     -l : clean log files"
   echo "     -t : create thumbnails"
   echo "     -r : check for required commands"
   echo
   echo "     -h : print this message"
   echo "     -v : print version information"
   echo "     -p : print configuration parameters"
   echo "     -c : configure parameters"
}

### print script version

print_version () {
   echo
   echo "$MYNAME  Version $MYRELEASE"
   echo
}

### Check number of arguments
# parameters ($@): all arguments that were passed to the script by the shell

check_arguments() {
   if [ $# -eq 0 -o $# -gt 2 ]
   then
      echo
      echo $MYNAME: Wrong number of arguments.
      usage
      exit 1
   fi
}

### configure tex2pdf parameters interactively

configure() {
   echo
   echo Configuration for tex2pdf.
   echo The following answers are considered as defaults in later executions
   echo of $MYNAME. You can change these values by using option -c.
   echo The command-line options override these settings.
   echo

   echo "$MYNAME can set the papersize of the resulting PDF document."
   echo "Possible values are: a4paper, letterpaper, legalpaper, executivepaper."
   question "What papersize should be used?"
   PAPERSIZE=$RESPONSE
   echo

   echo "$MYNAME can use color for URLs in the document."
   if [ "$COLORLINKS" == "true" ]
   then
        questionYN "Should color be used for the URLs?" yes
   else
        questionYN "Should color be used for the URLs?" no
   fi
   if [ "$RESPONSE" == "yes" ]
   then
        COLORLINKS=true
   else
        COLORLINKS=false
   fi
   echo

   if [ "$COLORLINKS" == "true" ]
   then
        echo "It is possible to specify the URL color."
        echo "Some possible values are: red, green, cyan, blue, magenta, black."
        question "What URL color should be used?"
        URLCOLOR=$RESPONSE
        echo

        echo "It is possible to specify the citation color."
        echo "Some possible values are: red, green, cyan, blue, magenta, black."
        question "What citation color should be used?"
        CITECOLOR=$RESPONSE
        echo
   fi

   echo "The title of the resulting document can be specified."
   echo "Leave blank in order to used LaTeX document title."
   question "Resulting document title?"
   TITLE=$RESPONSE
   echo

   echo "The author information of the resulting document can be specified."
   echo "Leave blank in order to used LaTeX document author."
   question "Resulting document author?"
   AUTHOR=$RESPONSE
   echo

   echo "The output directory can be specified."
   echo "Leave blank in order to use the same directory as the input file."
   question "What output directory should be used?"
   PDFOUTDIR=$RESPONSE
   echo

   echo "The sed executable to use can be specified."
   echo "Leave blank in order to use the sed in the path."
   question "What sed executable should be used?"
   SEDEXE=$RESPONSE
   echo

   echo "The bibtex usage can be specified."
   echo "Possible values are: 'yes' (always run bibtex), 'no' (never run"
   echo "bibtex) and 'test' (scan tex file for a bibtex entry and run it"
   echo "if required)."
   question "How should bibtex be used?"
   BIBTEX=$RESPONSE
   echo

   echo "The maximal number of runs for pdflatex can be specified."
   question "What should be the maximum number of runs for pdflatex?"
   MAXRUNNO=$RESPONSE
   echo

   echo "The minimal number of runs for pdflatex can be specified."
   echo "Possible values are: 1 ... $MAXRUNNO."
   question "What should be the minimum number of runs for pdflatex?"
   MINRUNNO=$RESPONSE
   echo

   echo "The log file directory can be specified."
   echo "A possible choice is '/tmp/tex2pdf-$USER'."
   question "What should be the log file directory?"
   LOGDIR=$RESPONSE
   echo

   echo "$MYNAME can clean the log files before execution."
   echo "You might experience problems if you run $MYNAME on several documents"
   echo "the same time. If you want to be on the safe side, answer 'no'."
   questionYN "Should the log files be cleaned before execution?" $CLEANLOGS
   CLEANLOGS=$RESPONSE
   echo

   echo "$MYNAME can check for the required executables."
   questionYN "Should $MYNAME check for the required executables?" $COMMANDCHECK
   COMMANDCHECK=$RESPONSE
   echo

   echo "$MYNAME can use thumbpdf to include thumbnails of the document pages."
   echo "This requires Ghostscript 5.50 or higher."
   questionYN "Should PNG thumbnails be created?" $THUMB
   THUMB=$RESPONSE
   echo

   echo "$MYNAME can force the call of makeindex if pdftex fails to do this."
   questionYN "Should the call of makeindex be forced?" $MAKEINDEX
   MAKEINDEX=$RESPONSE
   echo

   echo "Additional options for pdflatex can be specified."
   echo "You can leave this blank."
   question "What additional options for pdflatex should be used."
   PDFTEXOPTS="$RESPONSE"
   echo
}

### save configuration in rc file

write_configuration() {
   if ! echo "# Configuration file for $MYNAME V$MYRELEASE" > $RC_FILE
   then
      abort Couldn\'t write confguration file $RC_FILE
   fi
   echo "# Generated `date` by $USER on $HOSTNAME" >> $RC_FILE
   echo PAPERSIZE=$PAPERSIZE >> $RC_FILE
   echo COLORLINKS=$COLORLINKS >> $RC_FILE
   echo URLCOLOR=$URLCOLOR >> $RC_FILE
   echo CITECOLOR=$CITECOLOR >> $RC_FILE
   echo TITLE=$TITLE >> $RC_FILE
   echo AUTHOR=$AUTHOR >> $RC_FILE
   echo PDFOUTDIR=$PDFOUTDIR >> $RC_FILE
   echo SEDEXE=$SEDEXE >> $RC_FILE
   echo BIBTEX=$BIBTEX >> $RC_FILE
   echo MAXRUNNO=$MAXRUNNO >> $RC_FILE
   echo MINRUNNO=$MINRUNNO >> $RC_FILE
   echo LOGDIR=$LOGDIR >> $RC_FILE
   echo CLEANLOGS=$CLEANLOGS >> $RC_FILE
   echo PDFTEXOPTS=$PDFTEXOPTS >> $RC_FILE
   echo COMMANDCHECK=$COMMANDCHECK >> $RC_FILE
   echo THUMB=$THUMB >> $RC_FILE
   echo TMPBASESUFFIX=$TMPBASESUFFIX >> $RC_FILE
   echo MAKEINDEX=$MAKEINDEX >> $RC_FILE
   echo INSERTCOMMAND=$INSERTCOMMAND >> $RC_FILE
   echo "# EOF" >> $RC_FILE
}

### print the configuration parameters
print_configuration() {
   echo "Configuration for $MYNAME V$MYRELEASE"
   echo PAPERSIZE=$PAPERSIZE
   echo COLORLINKS=$COLORLINKS
   echo URLCOLOR=$URLCOLOR
   echo CITECOLOR=$CITECOLOR
   echo TITLE=$TITLE
   echo AUTHOR=$AUTHOR
   echo PDFOUTDIR=$PDFOUTDIR
   echo SEDEXE=$SEDEXE
   echo BIBTEX=$BIBTEX
   echo MAXRUNNO=$MAXRUNNO
   echo MINRUNNO=$MINRUNNO
   echo LOGDIR=$LOGDIR
   echo CLEANLOGS=$CLEANLOGS
   echo PDFTEXOPTS=$PDFTEXOPTS
   echo COMMANDCHECK=$COMMANDCHECK
   echo THUMB=$THUMB
   echo TMPBASESUFFIX=$TMPBASESUFFIX
   echo MAKEINDEX=$MAKEINDEX
   echo INSERTCOMMAND=$INSERTCOMMAND
   echo
}

### load parameters from rc file

read_configuration() {
   if [ ! -r $RC_FILE ]
   then
      echo $MYNAME: $RC_FILE doesn\'t exist or is not readable
      abort Couldn\'t read configuration file
   fi

   for i in PAPERSIZE COLORLINKS URLCOLOR CITECOLOR TITLE AUTHOR PDFOUTDIR SEDEXE BIBTEX MAXRUNNO MINRUNNO LOGDIR CLEANLOGS PDFTEXOPTS COMMANDCHECK THUMB TMPBASESUFFIX MAKEINDEX INSERTCOMMAND
   do
      TEMPVAR=`sed -n "s/^\($i=[[:print:]]*\)$/\1/1p" $RC_FILE`
      if [ -n "$TEMPVAR" ]
      then
        export $i=`echo $TEMPVAR | cut -d = -f 2-`
      fi
   done
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

### Removing all temporary files

clean_up() {
   echo $MYNAME: Removing temporary files ...
   [ -n "$TMPFILES" ] && rm $TMPFILES
   [ -n "$TMPBASE" ] && rm ${TMPBASE}.*
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

##### Check arguments
echo
echo "$MYNAME: Processing given parameters and arguments."
check_arguments $@

##### command line options and private configuration files handling
if [ "$USE_EXTENDED_OPTIONS" = yes ]
then

   CONFIGURE_REQ=no

   ### scan parameters (1st level)

   OPTIND=1
   while getopts hvpc OPTION
   do
      case "$OPTION" in
         h) help; exit 0 ;;
         v) print_version; exit 0 ;;
         p) PRINT_ONLY=yes ;;
         c) CONFIGURE_REQ=yes;;
         *) usage; exit 1 ;;
      esac
   done

   ### set parameters from rc file
   if [ -f "$RC_FILE" ]
   then
     read_configuration
   else
     if [ "$PRINT_ONLY" != yes ]
     then
        CONFIGURE_REQ=yes
     fi
   fi

   ### configure parameters
   if [ "$CONFIGURE_REQ" = "yes" ]
   then
     configure
     write_configuration
   fi

   ### scan parameters (2nd level)
   ### second level scan should be put here !!!
   while getopts itlr OPTION
   do
     case "$OPTION" in
       i) MAKEINDEX=yes ;;
       t) THUMB=yes ;;
       r) COMMANDCHECK=yes ;;
       l) CLEANLOGS=yes ;;
     esac
   done

   ### print configuration parameters

   if [ "$PRINT_ONLY" = "yes" ]
   then
      print_configuration
      exit 0
   fi

   #### remove all command line options, leave the document argument as $1
   shift $(($OPTIND - 1))
fi

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
   echo "Removing old log files ($LOGDIR)."
   rm ${LOGDIR}pdflatex-*.log ${LOGDIR}bibtex-*.log ${LOGDIR}thumbpdf-*.log
else
   echo
   echo "All log files will be stored in ($LOGDIR)."
fi

# setting the log files for the output of pdflatex, bibtex and thumbpdf
PDFLOGFILE=${LOGDIR}pdflatex-$$.log
BIBTEXLOG=${LOGDIR}bibtex-$$.log
THUMBPDFLOG=${LOGDIR}thumbpdf-$$.log

### make sure that TMPBASESUFFIX is not empty
if [ -z "$TMPBASESUFFIX" ]
then
   echo
   echo "$MYNAME: CAUTION: Parameter TMPBASESUFFIX is not set."
   echo "Running $MYNAME with this settings would destroy the original files!"
   echo "Aborting ..."
   exit 1
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
echo "$MYNAME: Analysing your document argument."

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

