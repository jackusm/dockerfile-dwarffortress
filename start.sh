#!/bin/bash

PRINTMODE=""
while getopts ":hp:" OPTION
do
    case $OPTION in
        h)
            /launch_df -h
            exit 1
            ;;
        p)
            PRINTMODE=$OPTARG
            ;;
    esac
done

# First if print mode is text we can just launch
if [[ $PRINTMODE == "TEXT" ]]; then
    /launch_df "$@"
    exit
fi

# Check for the presence of DISPLAY and if the user wants just launch
if [ "$DISPLAY" != "" ] ; then
    echo "found DISPLAY $DISPLAY"
    normed="a$DISPLAY"
    parts=(${normed//:/ })
    dnum=${parts[1]}
    echo "/tmp/.X11-unix/X$dnum"
    if [ -e "/tmp/.X11-unix/X$dnum" ] ; then
        read -p "It seems you can run without xpra. continue without xpra? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            /launch_df "$@"
            exit
        fi
    fi
fi

# At this point we assume xpra is required so we launch in that
/usr/bin/supervisord
/wait-for-daemons.sh xpra sshd
echo 'use the following command to connect: xpra attach --ssh=\"ssh -p PORT\" ssh:xpra@HOST:100'
read -p 'Press any key to launch Dwarf Fortress...'
su -l xpra -c 'DISPLAY=:100 /launch_df "$0" "$@"' -- "$@"