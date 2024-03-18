#!/bin/bash

#USAGE: MAIN.SH FILE FOLDER FOLDER1 FOLDER2 FOLDER3...
#WILL MOVE FILE TO FOLDER AND CHECK FOLDER1, 2 AND 3 FOR SYMLINKS

OLD_PWD=$PWD #NOT TO BE MISTAKEN WITH GOOD OL' OLDPWD
cd $2
FINAL_PWD=$PWD
cd $OLD_PWD

symlink_checker () { #checks recursively if symbolic links are inside folder. Stores links in arrays.
    local -n ARRAY=$1
    while IFS= read -r -d $'\0';
    do
        ARRAY+=("$REPLY");
    done < <(find ~+ -type l -print0)
}
###CHECKING IF FILE OR FOLDER OR NONE
if [ -d $1 ]
    then TYPE="FOLDER";
elif [ -f $1 ]
    then TYPE="FILE";
else TYPE="UNKNOWN";
fi
###GETTING SEPARATED FILE NAME AND ABSOLUTE PATH
if [ $TYPE = "FOLDER" ]
    then cd $1;
        FINAL_PATH=$PWD;
        cd -
elif [ $TYPE = "FILE" ]
    then
    JUST_FILENAME="$(basename -- $1)"
    path=`readlink -f "$1"`
    JUST_DIRNAME="$(dirname "$path")"
else
    exit 0
fi
###Using symlink checker to find symlinks
if [ -z $3 ] #if no $3, just do it in current folder
    then
        cd ./
        links=()
        symlink_checker links
else         #else, go trough every listed folder in args
    iterator=2
        at_array=( $@ )
        links=()
    while [ ! -z ${at_array[$iterator]} ]
        do
            cd ${at_array[$iterator]}
            symlink_checker links
            cd $OLD_PWD
            iterator=$iterator+1
        done
fi
###Itrating over link to get separated linkname, filepath and link actual path
printf "All links detected: \n \n"
for link in ${links[@]}
do
    link_readlink=`readlink -f "$link"`
    actual_thing=`readlink -f "$OLD_PWD/$1"`
    if [ "$link_readlink" = "$actual_thing" ]; then
        LINK_NAME="$(basename -- $link)"
        LINK_PATH="$(dirname "$link")"
        LINK_ALMOST_POINTER_PATH=`readlink "$link"`
        LINK_POINTER_PATH="$(dirname "$LINK_ALMOST_POINTER_PATH")"
        LINK_POINTER_NAME="$(basename -- $LINK_ALMOST_POINTER_PATH)"
        echo "$LINK_PATH/$LINK_NAME is link to $LINK_POINTER_PATH/$LINK_POINTER_NAME"
    fi
done
printf "\nDo you wish to: redo all links (y or enter), do nothing (n) or\nprint all links in file and exit (type filename and enter)?\n\r"

read user_answer
if [[ $user_answer = "y" || $user_answer = "" || $user_answer = "Y" ]]; then
for link in ${links[@]}   #the magic happens here. Redirecting links to new filepath.
    do
        link_readlink=`readlink -f "$link"`
        actual_thing=`readlink -f "$OLD_PWD/$1"`
        if [ "$link_readlink" = "$actual_thing" ]; then
            LINK_NAME="$(basename -- $link)"
            LINK_PATH="$(dirname "$link")"
            LINK_ALMOST_POINTER_PATH=`readlink "$link"`
            LINK_POINTER_PATH="$(dirname "$LINK_ALMOST_POINTER_PATH")"
            LINK_POINTER_NAME="$(basename -- $LINK_ALMOST_POINTER_PATH)"
            ##SO NOW WE HAVE ALL WE NEED TO KNOW ABOUT THE LINKS. LETS USE IT.##
            if [[ "$LINK_POINTER_PATH/$LINK_POINTER_NAME" = *".."* ]]; then
                cd $LINK_PATH
                current_try="$LINK_POINTER_PATH"
                while [ ! "`readlink -f $current_try/$2`" = "`readlink -f $FINAL_PWD`" ]; do
                    current_try=${current_try%..*}
                done
                unlink $LINK_NAME
                ln -s "$current_try/$2/$1" $LINK_NAME
                cd -
            else
                cd $LINK_PATH
                unlink $LINK_NAME
                ln -s "$FINAL_PWD/$LINK_POINTER_NAME" $LINK_NAME
                cd -
            fi
        fi
    done
exit 0
fi
if [[ $user_answer = "n" || $user_answer = "N" ]]; then
    exit 0
fi
if [[ ! $user_answer = "" || $user_answer = "*" ]]; then
if test -f "$user_answer"; then
    echo "File already exists. Exiting."
    exit 0
fi
touch $user_answer
for link in ${links[@]}
    do
        link_readlink=`readlink -f "$link"`
        actual_thing=`readlink -f "$OLD_PWD/$1"`
        if [ "$link_readlink" = "$actual_thing" ]; then
            LINK_NAME="$(basename -- $link)"
            LINK_PATH="$(dirname "$link")"
            LINK_ALMOST_POINTER_PATH=`readlink "$link"`
            LINK_POINTER_PATH="$(dirname "$LINK_ALMOST_POINTER_PATH")"
            LINK_POINTER_NAME="$(basename -- $LINK_ALMOST_POINTER_PATH)"
            echo "$LINK_PATH/$LINK_NAME --is link to--> $LINK_POINTER_PATH/$LINK_POINTER_NAME" >> $user_answer
        fi
    done
echo "done. No links fixed, just log written."
fi
printf "Finally move file? If there is any symlink in previous folder\n it will be overriden by file. That shouldnt be a problem,\nshould it?\ny tmo move file, n for not moving file."
read user_input

if [ $user_input = "y" || $user_input = "Y" ]; then
    echo "moving file..."
    mv $1 $2 #actually moving file
    echo "done."
    exit 0
elif [ $user_input = "n" || $user_input = "N" ]; then
    echo "Ok but all symlinks have already been moved. They are probably broken now."
    exit 0
else
    echo "Unknown answer. Exiting without moving files. Leaving symlinks broken. You can fix that by doing 'mv $1 $2'"
fi
