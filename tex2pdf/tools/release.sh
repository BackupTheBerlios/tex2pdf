#!/bin/bash
MAINNAME=tex2pdf-
ARCHIVE_SUFFIX=.tar.gz
TMP_DIR=$HOME/tmp
PATH_BASE=$HOME/devel/tex2pdf
BIN_DIR=$PATH_BASE/bin
WWW_DIR=$PATH_BASE/www
RELEASE_DIR=$PATH_BASE/releases
RELEASE_ARCHIVES=$RELEASE_DIR/archives
DATA_DIR=$PATH_BASE/tex2pdf/doc
VERSION=$1
NEW_RELEASE_DIR=$RELEASE_DIR/$MAINNAME$VERSION
RELEASE_ARCHIVE=$RELEASE_ARCHIVES/$MAINNAME$VERSION$ARCHIVE_SUFFIX

if [ -z "$VERSION" ]
then
 echo "Sorry. You must give a version string"
  echo "Aborting ..."
  exit 1
fi
 
if ! mkdir -p $RELEASE_ARCHIVES
then
  echo "Sorry. Could not create $RELEASE_ARCHIVES"
  echo "Aborting ..."
  exit 1
fi

if [ -d $NEW_RELEASE_DIR ]
then
  echo "$NEW_RELEASE_DIR exists. I will remove it."
  rm -rf $NEW_RELEASE_DIR
  rm -rf $RELEASE_ARCHIVE
fi

if ! mkdir $NEW_RELEASE_DIR
then
  echo "Sorry. Could not create $NEW_RELEASE_DIR"
  echo "Aborting ..."
  exit 1
fi

cd $BIN_DIR
echo "********* Checking tex2pdf *********"
cvs diff tex2pdf

if ! cp -a tex2pdf $NEW_RELEASE_DIR
then
  echo "Sorry. Could not copy tex2pdf"
  echo "Aborting ..."
  exit 1
fi

cd $WWW_DIR
echo
echo "********* Checking changelog.html *********"
cvs diff changelog.html

if ! html2text -nobs changelog.html > $TMP_DIR/tex2pdf-CHANGELOG.tmp
then
  echo "Sorry. Could not convert changelog.html to CHANGELOG"
  echo "Aborting ..."
  exit 1
fi

if ! sed -e '/^=\+$/a \
 ' -e "/\[.*Last modified.*\]/d " $TMP_DIR/tex2pdf-CHANGELOG.tmp > $NEW_RELEASE_DIR/CHANGELOG
then
  echo "Sorry. Could not adjust CHANGELOG"
  echo "Aborting ..."
  exit 1
fi

#echo "+++++++++ CHANGELOG ++++++++++"
#cat $NEW_RELEASE_DIR/CHANGELOG

echo
echo "********* Checking lyx-howto.htm *********"
cvs diff lyx-howto.htm

if ! html2text -nobs lyx-howto.htm > $NEW_RELEASE_DIR/README
then
  echo "Sorry. Could not generate README"
  echo "Aborting ..."
  exit 1
fi

echo "********* Adding gpl.txt *********"
if ! cp -p gpl.txt $NEW_RELEASE_DIR/LICENSE
then
  echo "Sorry. Could not copy LICENSE"
  echo "Aborting ..."
  exit 1
fi

#echo "+++++++++ README ++++++++++"
#cat $NEW_RELEASE_DIR/README

cd $RELEASE_DIR
if ! tar cfz $RELEASE_ARCHIVE $MAINNAME$VERSION
then
  echo "Sorry. Could not generate archive $MAINNAME$VERSION$ARCHIVE_SUFFIX"
  echo "Aborting ..."
  exit 1
fi

echo +++++++++++++ RELEASE NOTE ++++++++++
cat $DATA_DIR/release_note.html

echo +++++++++++++ CHANGELOG NOTE ++++++++++
cat $DATA_DIR/changelog_note.html

echo
echo "Archive is $RELEASE_ARCHIVES/$MAINNAME$VERSION$ARCHIVE_SUFFIX"
echo "Now upload to download.berlios.de/incoming/"

echo "Good luck!"
  
