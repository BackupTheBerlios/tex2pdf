#!/bin/bash

LOCAL_WWW_DIR=$HOME/devel/tex2pdf/www/
REMOTE_WWW_DIR=/home/groups/tex2pdf/htdocs/
REMOTE_HOST=shell.berlios.de
REMOTE_USER=$USER

if [ $# = 0 ]
then
   FILES="changelog.html index.html lyx-howto.htm help.txt"
else
   FILES="$*"
fi

cd $LOCAL_WWW_DIR

scp $FILES $REMOTE_USER@$REMOTE_HOST:$REMOTE_WWW_DIR
