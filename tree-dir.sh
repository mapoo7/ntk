#!/bin/bash
echo
if [ "$1" != "" ]
   then cd "$1"
   fi
pwd
ls -R | grep ":$" |   \
   sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
if [ `ls -F -1 | grep "/" | wc -l` = 0 ]
   then echo "   -> no sub-directories"
   fi
echo
exit
