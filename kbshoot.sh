#!/usr/bin/env bash

# kbfs-hosted screenshot program

# you need to have kbfs mounted
# run `run_keybase` and sign in

# requires: maim+slop OR scrot   (maim+slop recommended)
#           pngcrush
#           libimage-exiftool-perl
#           keybase
#           xclip

# user options
EXT="png" # png suggested, for pngcrush
SUBDIR="i" # the keybase subdirectory name to use
# end


# don't blame me if you touch anything below and it stops working

# function to check if program is installed
installed () {
    type "$1" &> /dev/null
}
# initial check for keybase
if ! installed keybase; then
    echo "  please install keybase."
    exit
fi

# see if keybase is logged in
LOGGED_IN_=$(keybase status | grep "Logged in")
LOGGED_IN="${LOGGED_IN_##* }"
if [ "$LOGGED_IN" != "yes" ]; then
    echo "  you are not logged into keybase"
    exit
fi

# get current keybase username
USER_=$(keybase status | grep Username)
USER="${USER_##* }"
# USER="lyk" # set this to your user if prev 2 lines get it wrong

# other prelim fs stuff
NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)
FILE="$NAME.$EXT"
TMP="/tmp/$SUBDIR"
FINAL="/keybase/public/$USER/$SUBDIR"
mkdir $TMP &> /dev/null
mkdir $FINAL &> /dev/null


# functions
show_help () {
    echo "  simple screenshot script for kbfs"
    echo "  https image link is copied to clipboard"
    echo ""
    echo "  requires keybase+kbfs"
    echo ""
    echo "  usage : kbshoot"
    echo "        : kbshoot -s"
    echo "        : kbshoot filename"
    echo ""
    echo "   args : none        fullscreen"
    echo "        : -s          select area"
    echo "        : filename    upload file"
    echo "        : -h --help   show this help"
    echo ""
    echo "   deps : maim+slop OR scrot"
    echo "        : pngcrush"
    echo "        : libimage-exiftool-perl"
    echo "        : keybase"
    echo "        : xclip"

    exit
}
dep_error () {
    echo "  you are missing one or more dependencies. see -h for details."
    exit
}
full_screen () {
    if installed maim; then
	maim --format=png --opengl --mask=on --nokeyboard $1
    elif installed scrot; then
	scrot -q 85 $1
    else
	dep_error
    fi
    echo "  screenshot taken"
    notify-send "screenshot taken"
}
select_area () {
    if installed maim; then
    maim --select --format=png --opengl --mask=on --magnify --bordersize 9001 --color=0.2,0.2,0.2,0.9 $1
    elif installed scrot; then
	scrot -s -q 85 $1
    else
	dep_error
    fi
    echo "  screenshot taken"
    notify-send "screenshot taken"
}
copy_file () {
    filename=$(basename "$1")
    EXT="${filename##*.}"
    FILE="$NAME.$EXT"
    cp $1 $TMP/$NAME.$EXT
}


# some dep checks
if ! installed exiftool; then
    dep_error
fi
if ! installed pngcrush; then
    dep_error
fi
if ! installed xclip; then
    dep_error
fi


# horribly simple arg logic
if [ $# -gt 1 ]; then
    show_help
fi

if [ $# -eq 0 ]; then
    full_screen $TMP/$FILE
fi

if [ $# -eq 1 ]; then
    if [ $1 == "-s" ]; then
	select_area $TMP/$FILE
    elif [ $1 == "-h" ] || [ $1 == "--help" ]; then
	 show_help
    else
	if [ -e $1 ]; then
	    copy_file $1
	else
	    echo "  file does not exist."
	    exit
	fi
    fi
fi


# strip all exif data
exiftool -all= $TMP/$FILE &> /dev/null


# pngcrush if file is a png
if [ $EXT == ".png" ]; then
    pngcrush $TMP/$FILE $FINAL/$FILE &> /dev/null
else
    # if not just copy it
    cp $TMP/$FILE $FINAL/$FILE &> /dev/null
fi

# kbfs hosted url
LINK="https://$USER.keybase.pub/$SUBDIR/$FILE"

printf "  "
# copies link to clipboards
echo -n $LINK | xclip -i -sel p -f | xclip -i -sel c -f
echo ""
notify-send "upload complete"
