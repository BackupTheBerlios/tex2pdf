#!/bin/bash

#      tex2pdf - script for translating latex docs to pdf
#
#      Copyright (C) 2000,2001 by Steffen Evers
#
#      This program is free software; you can redistribute it and/or modify
#      it under the terms of the GNU General Public License version 2 as 
#      published by the Free Software Foundation.
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
#      The GNU General Public License is also available online:
#      http://www.gnu.org/licenses/gpl.html
#
# Thanks a lot to all the people that have already contributed to this project!
#
# The changelog including the credits has become too long. So, I have removed it
# from the script, but it is still available online (see below). 
#
# Special thanks to the following people for their contribution
# (see the changelog for details):
# Matej Cepl, Herbert Voss, Nicolas Marsgui, Bruce Foster, Mark van Rossum,
# Matt Bandy, Garrick Chien Welsh, Stacy J. Prowell, Pavel Sedivy,
# Holger Daszler, Olaf Gabler, Ahmet Sekercioglui, Richard, Steffen Macke
#
# Project Homepage: http://tex2pdf.berlios.de
# Developer Homepage: http://developer.berlios.de/projects/tex2pdf
# Mailing lists: http://developer.berlios.de/mail/?group_id=57
# Changelog: http://tex2pdf.berlios.de/changelog.html
#
# Anyone is invited to help to improve tex2pdf. Therefore any kind of feedback
# is welcome. Maybe you even would like to hack the code and send us your
# changes. This would help a lot and is highly appreciated. Think about it :-)
# Subscribing to the developer mailing list might be a first step (see above).
#
# Send feedback to: tex2pdf-devel@lists.berlios.de
#

MYRELEASE="2.2.0"

##### You will need pdftex and epstopdf for the generation!
##### See pdftex homepage for details: http://tug.org/applications/pdftex/
##### Have fun!!!

##### Default parameters
## Change the parameters below if you want to change the default settings for
## all users.  If you only want to change your private parameters change them
## in the RC_FILE

### text token for no value
NIL=NOVALUE

### pdftex package options:
### see hyperref manual for more:/usr/share/texmf/doc/latex/hyperref/manual.pdf

# possible paper sizes
# this list MUST have the syntax "PAPER1 PAPER2 ..."
POSSIBLE_PAPER="a4paper letterpaper legalpaper executivepaper $NIL"

# papersize of the resulting pdf document
PAPERSIZE=a4paper

# use color for links in the resulting document
# options: 'yes' or 'no'
COLORLINKS=yes

# possible link colors
# this list MUST have the syntax "COLOR1 COLOR2 ..."
LINK_COLORS="yellow red green cyan blue magenta black $NIL"

# color to use for page links in resulting document
# some possible values: see above
# set to $NIL for default value
PAGECOLOR=magenta

# color to use for regular internal links in resulting document
# some possible values: see above
# set to $NIL for default value
LINKCOLOR=green

# color to use for URLS in resulting document
# some possible values: see above
# set to $NIL for default value
URLCOLOR=blue

# color to use for citations in resulting document
# some possible values: see above
# set to $NIL for default value
CITECOLOR=red

# Default title for document info in the resulting PDF 
# leave blank for default value
DEFAULT_TITLE="$NIL"

# Default author for document info in the resulting PDF 
# leave blank for default value
DEFAULT_AUTHOR="$NIL"

# additional parameters for hyperref package
# format: PARAMETERNAME={VALUE},PARAMETERNAME={VALUE},...
# leave blank for no additional values
ADDITIONAL_PARAMETERS=

# link tabel of contents to pages instead of sections
# sets linktocpage
LINKTOCPAGE=yes

### other parameters

# place where generated pdf file is stored:
# source_dir - same directory as the LaTeX file
# input_dir - same directory as the input files of the LaTeX file
# custom      - specified directory PDFCUSTOMDIR
PDFOUT=source_dir

# custom directory where the generated pdf file is stored
PDFCUSTOMDIR=$HOME

# usage of bibtex
# possible values: 'yes' (always run bibtex), 'no' (never run bibtex),
# 'test' (scan tex file for a bibtex entry and run it if required)
POSSIBLE_BIBTEX="yes no test"
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
THUMBNAILS="no"

# execution of the makeindex command for index handling
# this should fix the problem with a missing document index
# possible values: "yes" - check for index file and if found call makeindex
#                  "no"  - never execute it
MAKEINDEX="yes"

##### expert parameters
## the following parameters should NOT be modified by regular users!
## study the script carefully before you change them !!!

# the sed executable this script should use
# no value means script should use the sed in your path
SEDEXE=

# additional options for pdflatex
PDFTEXOPTS=""

# suffix for tmp files that will be put in between the basename and suffix of
# the original file
# CAUTION: If you leave this blank you will overwrite the original files!
TMPBASESUFFIX=-pdf

# remove all tmp files on abort
CLEAN_ON_ABORT=no

# sed command which is used to insert additional TeX commands in the LaTeX
# preamble
# try the following commands if you have strange errors or junk on the
# first PDF document page
# INSERTCOMMAND="/^[\]begin{document}$/i"
# INSERTCOMMAND="/^[\]makeatletter$/i"
INSERTCOMMAND="/^[\]documentclass\(\[[^]]*\]\)\?{.*}/a"

### file to store private parameters
# If you only want to change your private parameters change them there
# default: $HOME/.tex2pdfrc
RC_FILE=$HOME/.tex2pdfrc

# variables for the rc file
# list of all variables that should be stored/read in/from the rc file
# this list MUST have the syntax "VARIABLE1 VARIABLE2 ..."
RC_VARIABLES="PAPERSIZE COLORLINKS PAGECOLOR LINKCOLOR URLCOLOR CITECOLOR DEFAULT_TITLE DEFAULT_AUTHOR LINKTOCPAGE ADDITIONAL_PARAMETERS PDFOUT PDFCUSTOMDIR SEDEXE BIBTEX MAXRUNNO MINRUNNO LOGDIR CLEANLOGS PDFTEXOPTS COMMANDCHECK THUMBNAILS TMPBASESUFFIX MAKEINDEX INSERTCOMMAND"

##### Functions ###########################################

### Removing all temporary files

clean_up() {
   echo $MYNAME: Removing temporary files ...
   [ -n "$TMPFILES" ] && rm $TMPFILES
   [ -n "$TMPBASE" ] && rm ${TMPBASE}.*
}

###  exit with an error message

abort() {
   echo $MYNAME: "$@"
   [ "$CLEAN_ON_ABORT" == yes ] && clean_up
   echo Aborting ...
   exit 1
}

#### General functions (not script specific)

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

### interactively input a positive integer number
# $1 question
# $2 default value
# $3 min value
# $4 max value
# $RESPONSE: the input number

input_number() {
   local user_input
   while true; do
      echo -n "$1 [$2]: "
      read user_input </dev/tty
      if [ -z "$user_input" ]
      then
         RESPONSE=$2
         return
      else
         RESPONSE=`echo $user_input | sed -n "s/^\([[:digit:]]\+\)$/\1/p"`
         if [ -z "$RESPONSE" ] || [ $RESPONSE -lt $3 -o $RESPONSE -gt $4 ]
         then
            echo "Invalid input. Please enter a positve integer from $3 to $4."
         else
            return
         fi
      fi
   done
}

### interactively choose between several given values
# $1 question
# $2 default value
# $3 ... $x possible values
# $RESPONSE chosen value

chooseValue() {
   local DEFAULT_VALUE=$2
   local QUESTION=$1
   local INDEX=1
   local DEFAULT_NUMBER=1

   shift 2

   echo "$QUESTION"
   while [ $INDEX -le $# ]
   do
      echo "$INDEX) ${!INDEX}"
      [ "$DEFAULT_VALUE" = "${!INDEX}" ] && DEFAULT_NUMBER=$INDEX
      INDEX=$(($INDEX+1))
   done
   
   input_number "Please enter the corresponding number" $DEFAULT_NUMBER 1 $#
   RESPONSE="${!RESPONSE}"
}

### interactively answer a question
# $1: question
# $2: current value

input_text() {
   echo "Suggested value: $2"
   questionYN "Do you want to keep this value?" yes
   if [ "$RESPONSE" == yes ]
   then
      RESPONSE="$2"
   else
      echo -n "$1 "
      read RESPONSE </dev/tty
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
      abort "$MESSAGE"
   elif [ ! -r "$1" ]
   then
      echo
      echo "$MYNAME: Sorry. File '$1' exists, but is not readable."
      abort "$MESSAGE"
   fi
}

##### Make sure that specified directory exists and is writable
# return values: 0 - ok; 1 - error
# parameter $1: directory to check
# parameter $2: remark if check fails on specified directory
# paramter $3: if yes, creation is allowed

check_dir() {
   local MESSAGE=$2
   [ -z "$MESSAGE" ] && MESSAGE="Not a valid path!"

   if [ ! "`echo $1 | cut -b 1`" == "/" ]
   then
      echo
      echo "$MYNAME: Sorry. '$1' is not an absolute path."
      echo "$MESSAGE"
      return 1
   elif [ ! -d "$1" ]
   then
      # dir does not exist
      echo
      if [ "$3" == "yes" ]
      then
         # creation allowed
         echo "$MYNAME: I cannot find '$1'. Try to create it."
	 if mkdir "$1"
	 then
	    echo "Creation of '$1' was successful."
	    return 0
	 else
	    echo "$MYNAME: Creation of '$1' failed."
	    echo "$MESSAGE"
	    return 1
	 fi
      else
         # creation not allowed
         echo "$MYNAME: Sorry. Directory '$1' does not exist."
         echo "$MESSAGE"
         return 1
      fi
   elif [ ! -w "$1" ]
   then
      # dir not writable
      echo
      echo "$MYNAME: Sorry. Directory '$1' exists, but is not writable."
      echo "$MESSAGE"
      echo
      return 1
   fi
   return 0
}

### interactively input an directory for data storage (absolute path)
# $1 question
# $2 default dir
# $3 if 'yes' allow creation of directory
# $RESPONSE: the given directory 

input_dir() {
   local user_input
   local default_dir
   local question

   if [ "`echo $2 | cut -b 1`" == "/" ] \
      && [ ! -d "$2" -a "$3" == "yes" -o -d "$2" -a -w "$2" ]
   then
      default_dir="$2"
      question="$1 [$2]: "
   else
      default_dir=""
      question="$1: "
   fi

   while true; do
      echo -n "$question"
      read user_input </dev/tty
      if [ -z "$user_input" -a -n "$default_dir" ]
      then
         # user has only pressed <ENTER> and thereby confirmed default value
	 if ! check_dir "$default_dir" "Default value was not valid. Please, give different directory." "$3"
	 then
	    # default dir does not exist and cannot be created
	    default_dir=""
	    question="$1: "
	 else
	    # valid default dir has already existed or has been created
            RESPONSE="$default_dir"
            return
	 fi
      else
         # user has given a directory
         if check_dir "$user_input" "This is not a valid directory!" "$3"
         then
	    RESPONSE="$user_input"
            return
         fi
      fi
   done
}

### set a variable by a command line option to 'yes' or' no'; abort on error
# $1 variable
# $2 given value
# $3 Option letter

setYNValue() {
   case $2 in
      yes|y|Y|YES) export $1=yes ;;
      no|n|N|NO) export $1=no ;;
      *) echo
         echo "$1 requires 'yes' or 'no'." 
         abort "Illegal argument for option -$3: $2"
   esac
}

### set a variable by a command line option to a possible values; abort on error
# $1 variable
# $2 given value
# $3 Option letter
# $4 list of possible values

setValue() {
   if [ -z "`echo $4 | sed -n "\|$2|p"`" ]
   then
      echo
      echo "$1 allows: $4."
      abort "Illegal argument for option -$3: $2"
      exit 1
   fi
   export $1=$2
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

### save configuration in rc file

write_configuration() {
   if ! echo "# Configuration file for $MYNAME V$MYRELEASE" > $RC_FILE
   then
      abort "Couldn't write confguration file '$RC_FILE'"
   fi
   echo "# Generated `date` by $USER on $HOSTNAME" >> $RC_FILE
   for i in $RC_VARIABLES
   do
      echo $i=${!i} >> $RC_FILE
   done
   echo "# EOF" >> $RC_FILE
}

### print the configuration parameters
print_configuration() {
   echo "Configuration for $MYNAME V$MYRELEASE"
   for i in $RC_VARIABLES
   do
      echo $i=${!i}
   done
   echo
}

### load parameters from rc file

read_configuration() {
   if [ ! -r $RC_FILE ]
   then
      echo "$MYNAME: '$RC_FILE' does not exist or is not readable"
      abort "Couldn't read configuration file"
   fi

   for i in $RC_VARIABLES
   do
      TEMPVAR=`sed -n "s/^\($i=[[:print:]]*\)$/\1/1p" $RC_FILE`
      if [ -n "$TEMPVAR" ]
      then
        export $i="`echo $TEMPVAR | cut -d = -f 2-`"
      fi
   done
}

#### Specific functions (for use with this script only)

### print usage of command

usage () {
   echo
   echo "Usage: $MYNAME [OPTIONS] DOCUMENT.lyx"
   echo "       $MYNAME [OPTIONS] DOCUMENT.tex"
   echo "       $MYNAME [-h|-v|-o|-r]"
   echo
}

### print command help

help () {
   echo
   echo "$MYNAME  Version $MYRELEASE"
   usage
   echo " -h : print this message"
   echo " -v : print version information"
   echo " -o : print configuration parameters"
   echo " -r : run configure parameters"
   echo
   echo " -i BOOL   : makeindex"
   echo " -l BOOL   : clean log files"
   echo " -c BOOL   : check for required commands"
   echo " -n BOOL   : generate thumbnails for PDF document"
   echo " -t TITLE  : specify title for PDF document info"
   echo " -a AUTHOR : specify author for PDF document info"
   echo " -p SELECT : select papersize: $POSSIBLE_PAPER"
   echo " -b SELECT : select bibtex handling: $POSSIBLE_BIBTEX"
   echo " -d PATH   : custom directory where the final PDF is stored"
   echo
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
   if [ $# -eq 0 ]
   then
      echo
      echo $MYNAME: I need at least one argument!
      usage
      exit 1
   fi
}

### configure tex2pdf parameters interactively

configure() {
   echo
   echo Configuration for tex2pdf.
   echo The following answers are considered as defaults in later executions
   echo of $MYNAME. You can change these values by using option -r.
   echo The command-line options override these settings.
   echo "Many parameters can be set to '$NIL'. This means that NO value at"
   echo "all (not even an empty value) is passed over to the called"
   echo "application (e.g. latex package hyperref)."
   echo

   echo ----------------
   echo "$MYNAME can set the papersize of the resulting PDF document."
   chooseValue "What papersize should be used?" $PAPERSIZE $POSSIBLE_PAPER
   PAPERSIZE=$RESPONSE
   echo

   echo ----------------
   echo "The table of contents of the resulting PDF document is normally linked"
   echo "to the corresponding section. However, you can also link it to the"
   echo "corresponding page instead."
   questionYN "Should TOC be linked to pages?" $LINKTOCPAGE
   LINKTOCPAGE=$RESPONSE
   echo

   echo ----------------
   echo "$MYNAME can use different colors for links inside the PDF document."
   questionYN "Should colors be used for links?" $COLORLINKS
   COLORLINKS=$RESPONSE
   echo

   if [ "$COLORLINKS" == "yes" ]
   then
        echo ----------------
        echo "It is possible to specify the color for page links."
        chooseValue "What color should be used for page links?" $PAGECOLOR $LINK_COLORS
        PAGECOLOR=$RESPONSE
        echo

        echo ----------------
        echo "It is possible to specify the color for normal internal links."
        chooseValue "What color should be used for normal links?" $LINKCOLOR $LINK_COLORS
        LINKCOLOR=$RESPONSE
        echo

        echo ----------------
        echo "It is possible to specify the URL color."
        chooseValue "What color should be used for URLs?" $URLCOLOR $LINK_COLORS
        URLCOLOR=$RESPONSE
        echo

        echo ----------------
        echo "It is possible to specify the citation color."
        chooseValue "What color should be used for citation?" $CITECOLOR $LINK_COLORS
        CITECOLOR=$RESPONSE
        echo
   fi

   echo ----------------
   echo "A PDF document contains meta data about itself: the document info."
   echo "Two of the info fields (title, author) can be set here as default"
   echo "value which will be used in the case that $MYNAME cannot determine"
   echo "proper settings from the LaTeX document."
   echo

   echo "The default title for the document info of all generated documents."
   echo "$NIL will be recognized."
   echo
   input_text "Default document title?" "$DEFAULT_TITLE"
   DEFAULT_TITLE="$RESPONSE"
   echo

   echo ----------------
   echo "The default author for the document info of all generated documents."
   echo "$NIL will be recognized."
   echo
   input_text "Default document author?" "$DEFAULT_AUTHOR"
   DEFAULT_AUTHOR="$RESPONSE"
   echo

   echo ----------------
   echo "If you like you can make me pass additional parameters to hyperref."
   echo "See the hyperref manual for possible values and details."
   echo "These parameters should normally have the format:"
   echo "PARAMETERNAME={VALUE},PARAMETERNAME={VALUE},..."
   echo "Leave blank for no additional values."
   echo
   input_text "Additional parameters ?" "$ADDITIONAL_PARAMETERS"
   ADDITIONAL_PARAMETERS="$RESPONSE"
   echo

   echo ----------------
   echo "You can now specify in which directory the resulting document should"
   echo "be written by default:"
   echo "- 'source_dir' means the same directory as the LaTeX file."
   echo "- 'input_dir' means the same directory as the input files of your"
   echo "  LaTeX file (e.g. images, included documents, etc.)."
   echo "  This path should be specified in the source LaTeX document otherwise"
   echo "  it is identical with the 'source_dir' option."
   echo "- 'custom' means you want to specify your own directory where the"
   echo "  generated document should be written."
   chooseValue "Which output directory?" $PDFOUT source_dir input_dir custom 
   PDFOUT=$RESPONSE
   echo
   
   if [ "$PDFOUT" == "custom" ]
   then
      echo ----------------
      echo "You have choosen to specifiy a custom output directory."
      input_dir "What custom directory should be used?" "$PDFCUSTOMDIR" "yes"
      PDFCUSTOMDIR=$RESPONSE
      echo
   fi

   echo ----------------
   echo "The sed executable to use can be specified."
   echo "Leave blank in order to use the sed in the path."
   echo
   input_text "What sed executable should be used?"
   SEDEXE=$RESPONSE
   echo

   echo ----------------
   echo "The bibtex usage can be specified."
   echo "Possible values are: 'yes' (always run bibtex), 'no' (never run"
   echo "bibtex) and 'test' (scan tex file for a bibtex entry and run it"
   echo "if required)."
   chooseValue "How should bibtex be used?" $BIBTEX $POSSIBLE_BIBTEX
   BIBTEX=$RESPONSE
   echo

   echo ----------------
   echo "The maximal number of runs for pdflatex can be specified."
   input_number "What should be the maximum number of runs for pdflatex?" $MAXRUNNO 1 9
   MAXRUNNO=$RESPONSE
   echo

   echo ----------------
   echo "The minimal number of runs for pdflatex can be specified."
   echo "Possible values are: 1 ... $MAXRUNNO."
   input_number "What should be the minimum number of runs for pdflatex?" $MINRUNNO 1 $MAXRUNNO
   MINRUNNO=$RESPONSE
   echo

   echo ----------------
   echo "The log directory is used to store information about the generation"
   echo "process for later review, e.g. for debugging."
   input_dir "What log directory should be used?" "$LOGDIR" "yes"
   LOGDIR=$RESPONSE
   echo

   echo ----------------
   echo "$MYNAME can clean the log files before execution."
   echo "You might experience problems if you run $MYNAME on several documents"
   echo "the same time. If you want to be on the safe side, answer 'no'."
   questionYN "Should the log files be cleaned before execution?" $CLEANLOGS
   CLEANLOGS=$RESPONSE
   echo

   echo ----------------
   echo "$MYNAME can check for the required executables."
   questionYN "Should $MYNAME check for the required executables?" $COMMANDCHECK
   COMMANDCHECK=$RESPONSE
   echo

   echo ----------------
   echo "$MYNAME can use thumbpdf to include thumbnails of the document pages."
   echo "This requires Ghostscript 5.50 or higher."
   questionYN "Should PNG thumbnails be created?" $THUMBNAILS
   THUMBNAILS=$RESPONSE
   echo

   echo ----------------
   echo "$MYNAME can force the call of makeindex if pdftex fails to do this."
   questionYN "Should the call of makeindex be forced?" $MAKEINDEX
   MAKEINDEX=$RESPONSE
   echo

   echo ----------------
   echo "Additional options for pdflatex can be specified."
   echo "Normally, you can leave this blank."
   echo
   input_text "What additional options for pdflatex should be used? :"
   PDFTEXOPTS="$RESPONSE"
   echo
}

### check if the most important executables are installed on the system
# parameters: none

check_commands() {
   ### check for which command
   checkCommand which "You can switch off all command checks by setting COMMANDCHECK=no in the parameter section of $MYNAME."

   ### sed executable
   # GNU sed version 3.02 or higher is recommended
   # Download: ftp://ftp.gnu.org/pub/gnu/sed
   if [ "$SEDEXE" = "sed" ]
   then
      checkCommand sed "You should get GNU sed 3.02 or later: ftp://ftp.gnu.org/pub/gnu/sed"
   fi

   ### pdftex executables
   # Homepage: http://tug.org/applications/pdftex
   checkCommand pdflatex "See pdftex homepage for details: http://tug.org/applications/pdftex"
   checkCommand epstopdf "See pdftex homepage for details: http://tug.org/applications/pdftex"

   if [ "$THUMBNAILS" = "yes" ]
   then
      checkCommand thumbpdf "You can switch off thumbpdf support by setting THUMBNAILS=no in the parameter section of $MYNAME."
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

### generate hyperref parameters from given settings
# HYPERREF_PARAMS: result

generate_parameters() {
   local PARAMS=pdftex
   [ "$PAPERSIZE" != "$NIL" ] && PARAMS="$PARAMS,$PAPERSIZE"
   [ "$LINKTOCPAGE" == "yes" ] && PARAMS="$PARAMS,linktocpage"
   [ "$TITLE" != "$NIL" ] && PARAMS="$PARAMS,pdftitle={$TITLE}"
   [ "$AUTHOR" != "$NIL" ] && PARAMS="$PARAMS,pdfauthor={$AUTHOR}"
   if [ "$COLORLINKS" == yes ]
   then
      PARAMS="$PARAMS,colorlinks=true"
      [ "$LINKCOLOR" != "$NIL" ] && PARAMS="$PARAMS,linkcolor={$LINKCOLOR}"
      [ "$PAGECOLOR" != "$NIL" ] && PARAMS="$PARAMS,pagecolor={$PAGECOLOR}"
      [ "$URLCOLOR" != "$NIL" ] && PARAMS="$PARAMS,urlcolor={$URLCOLOR}"
      [ "$CITECOLOR" != "$NIL" ] && PARAMS="$PARAMS,citecolor={$CITECOLOR}"
   else
      PARAMS="$PARAMS,colorlinks=false"
   fi
   [ -n "$ADDITIONAL_PARAMETERS" ] && PARAMS="$PARAMS,$ADDITIONAL_PARAMETERS"
   HYPERREF_PARAMS="$PARAMS"
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

   ### if thumbnails should be generated thumbdf package must be used
   if [ "$THUMBNAILS" = "yes" ]
   then
      THUMBPDF_INSERT='\\usepackage{thumbpdf}'
   else
      THUMBPDF_INSERT="% no thumbpdf support"
   fi
      
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
   '"$THUMBPDF_INSERT" \
   -e "$INSERTCOMMAND"' \
   \\makeatletter' \
   -e "$INSERTCOMMAND"' \
   \\usepackage['"$HYPERREF_PARAMS]{hyperref}"  \
   -e "$INSERTCOMMAND"' \
   \\makeatother' \
   $1 > $TARGETFILE

   ### Convert all EPS images to pdf
   [ -n "$EPSIMAGES" ] && convert_eps2pdf $EPSIMAGES

   ### Convert all PSTEX_T files to PDF_T
   [ -n "$PSTEXS" ] && convert_pstex2pdf $PSTEXS

   echo
   echo "Finished: ${TEXSOURCE}."
}

### run pdflatex
# parameter $1: LaTeX file without extension
# parameter $2: log-file where the full out put is stored
# return value: 0 - no errors (no rerun); 1 - errors (rerun required)

run_pdflatex() {
   local TEXFILE=$1
   local errors=0
   local PDFLOGFILE=$2
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
	 abort "Fatal error occured. I am lost."
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
TITLE=
AUTHOR=

echo
echo "$MYNAME: Script starts (Release $MYRELEASE)"

##### Check arguments
echo
echo "$MYNAME: Processing given parameters and arguments."
check_arguments $@

##### command line options and private configuration files handling
CONFIGURE_REQ=no

### scan parameters (1st level)
OPTIND=1
while getopts hvorb:c:p:i:t:a:l:n:d: OPTION
do
   case "$OPTION" in
      h) help; exit 0 ;;
      v) print_version; exit 0 ;;
      o) PRINT_ONLY=yes ;;
      r) CONFIGURE_REQ=yes;;
	 b|c|p|i|t|a|l|n|d) ;;
      *) usage; exit 1 ;;
   esac
done

### set parameters from rc file
if [ -f "$RC_FILE" ]
then
  read_configuration
else
  if [ "$PRINT_ONLY" != "yes" -a "$CONFIGURE_REQ" != "yes" ]
  then
     abort "Script is not configured. Please run $MYNAME -r."
  fi
fi

### configure parameters
if [ "$CONFIGURE_REQ" = "yes" ]
then
  configure
  write_configuration
  print_configuration
  exit 0
fi

### scan parameters (2nd level)
OPTIND=1
while getopts b:p:i:t:a:l:c:n:d: OPTION
do
  case "$OPTION" in
    i) setYNValue MAKEINDEX $OPTARG i ;;
    t) TITLE=$OPTARG ;;
    a) AUTHOR=$OPTARG ;;
    b) setValue BIBTEX $OPTARG b "$POSSIBLE_BIBTEX" ;;
    p) setValue PAPERSIZE $OPTARG p "$POSSIBLE_PAPER" ;;
    c) setYNValue COMMANDCHECK $OPTARG r ;;
    n) setYNValue THUMBNAILS $OPTARG n ;;
    l) setYNValue CLEANLOGS $OPTARG l ;;
    d) if check_dir $OPTARG
       then
	     PDFCUSTOMDIR="$OPTARG"
	     PDFOUT=custom
	  else
	     abort "Please, choose a VALID path."
	  fi ;;
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

### make sure that TMPBASESUFFIX is not empty
if [ -z "$TMPBASESUFFIX" ]
then
   echo
   echo "$MYNAME: CAUTION: Parameter TMPBASESUFFIX is not set."
   abort "Using these settings would destroy the original files!"
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

### set some more variables

# setting the log files for the output of pdflatex, bibtex and thumbpdf
PDFLOGBASE=${LOGDIR}pdflatex-$$-
BIBTEXLOG=${LOGDIR}bibtex-$$.log
THUMBPDFLOG=${LOGDIR}thumbpdf-$$.log

##### Get title and author from main LaTeX document
echo
echo $MYNAME: Parsing LaTeX file
if [ -z "$TITLE" ]
then
   TITLE=`${SEDEXE} -n "s/^.*[\]title{\([^{}]*\)}.*$/\1/1p" $PASSEDTEXDOC`
   if [ -z "$TITLE" ]
   then
      echo
      echo "$MYNAME: WARNING: Could not identify document's title correctly."
      echo "Maybe you have used a LaTeX Tag inside the title which confuses me."
      echo "You can either set a title on the command line using option -t or"
      echo "change the title of the LaTeX file in order to avoid the problem."
      if [ -n "$DEFAULT_TITLE" ]
      then
         echo "Using default title: $DEFAULT_TITLE"
	 TITLE="$DEFAULT_TITLE"
      else
         echo "Title field will be empty."
      fi
   else
     echo "Document's title: $TITLE"
   fi
fi

if [ -z "$AUTHOR" ]
then
   AUTHOR=`${SEDEXE} -n "s/^.*[\]author{\([^{}]*\)}.*$/\1/1p" $PASSEDTEXDOC`
   if [ -z "$AUTHOR" ]
   then
      echo
      echo "$MYNAME: WARNING: Could not identify document's author correctly."
      echo "Maybe you have used a LaTeX Tag inside the author field which confuses me."
      echo "You can either set an author on the command line using option -a or"
      echo "change the author of the LaTeX file in order to avoid the problem."
      if [ -n "$DEFAULT_AUTHOR" ]
      then
         echo "Using default title: $DEFAULT_AUTHOR"
	 AUTHOR="$DEFAULT_AUTHOR"
      else
         echo "Author field will be empty."
      fi
   else
     echo "Document's author: $AUTHOR"
   fi
fi

echo

# translate hyperref settings to the actual package parameters 
generate_parameters

###### change working directory to INPUTPATH if set
# When the files' path (images, included documents, etc.) in your document is
# relative to another directory than the PASSED document's directory.
# This is useful when the calling application (e.g. LyX) generates a temporary
# TeX file and calls the tex2pdf with it instead of the original file.
INPUTPATH=`sed -n "s|^[\]def[\]input@path{\+\([^{}]*\)}\+|\1|1p" $PASSEDTEXDOC`

## check if INPUTPATH is ok
if [ -n "$INPUTPATH" ]
then
   echo "$MYNAME: Found an input path in the latex document: $INPUTPATH"
   if [ -d "$INPUTPATH" -a -r "$INPUTPATH" ]
   then
      echo "Change working directory to input path."
      cd $INPUTPATH
   else
       abort "The retrieved input@path seems not to be valid."
   fi
else
   echo "$MYNAME: No input path in the latex document found."
   echo "Resources are expected to be relative to document's location: $DOCPATH"
fi

# set the directory where the final pdf will be stored
PDFOUTDIR=
case $PDFOUT in
   custom) PDFOUTDIR=$PDFCUSTOMDIR ;;
   input_dir) PDFOUTDIR=$INPUTPATH ;;
   source_dir) PDFOUTDIR=$DOCPATH ;;
esac

[ -z "$PDFOUTDIR" ] && PDFOUTDIR=$DOCPATH

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
   if run_pdflatex ${TMPBASE} "${PDFLOGBASE}${runno}.log" && [ $MINRUNNO -le $runno ]
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

### if the THUMBNAILS option is switched on then make thumbnails
if [ "$THUMBNAILS" = "yes" ]
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
   run_pdflatex ${TMPBASE} "${PDFLOGBASE}${runno}.log"
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

