#!/bin/bash

function getopt_test() {
    args=`getopt abo: $*`
    if [ $? != 0 ]; then
       echo 'Usage: ...'
       exit 2
    fi
    set -- $args

    for i; do
       case "$i"
       in
           -a|-b)
               echo flag $i set; sflags="${i#-}$sflags";
               shift;;
           -o)
               echo oarg is "'"$2"'"; oarg="$2";
               shift 2;;
           --)
               shift; break;;
       esac
    done

    echo single-char flags: "'"$sflags"'"
    echo oarg is "'"$oarg"'"    

    for arg in $*; do
        echo "processing: $arg"
    done
}

getopt_test -ab -o argtest file1 file2
#end
