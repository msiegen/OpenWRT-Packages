#!/bin/sh
#### Description: USB autorun script for the Onion Omega2
#### Pleace autorun.sh and auth.txt under the USB root directory
#### Written by: Onion Corporation https://onion.io

authFile="auth.txt"
scriptFile="autorun.sh"
logFile="autorun.log"
usbPath=""
usbPath1="/mnt/sda1"
usbPath2="/mnt/sda"

. /lib/ramips.sh
ledPath="/sys/class/leds/$(ramips_board_name):amber:system"

log_write () {
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] " $1 >> $usbPath/$logFile
}

blink_start () {
    echo timer > $ledPath/trigger
    echo 100 > $ledPath/delay_on
    echo 100 > $ledPath/delay_off
}

blink_stop () {
    echo default-on > $ledPath/trigger
}

end () {
    blink_stop
    exit 0
}

check_auth () {
    if [ -e $usbPath/$authFile ]; then

        USERNAME=`sed '1!d' $usbPath/$authFile`
        PASSWORD=`sed '2!d' $usbPath/$authFile`

        ubus call session login "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}"
        if [ $? == 0 ]; then
            log_write "Auth OK"
        else
            log_write "Auth Fail. Please make sure auth.txt contains correct Omega username and password"
            end
        fi

    else
        log_write "auth.txt not found"
        end
    fi
}

usbAutorunStart () {
    sleep 2
    # do nothing if no autorun script is found
    [ -f $usbPath1/$scriptFile ] && {
        usbPath="$usbPath1"
    }
    [ -f $usbPath2/$scriptFile ] && {
        usbPath="$usbPath2"
    }
    
    [ "$usbPath" == "" ] && {
        end
    }

    blink_start
    log_write "Omega Autorun Started"
    check_auth

    sh $usbPath/$scriptFile >> $usbPath/$logFile

    blink_stop
    log_write "Omega Autorun Ended"
}


usbAutorunStop () {
    blink_stop
}

# run appropriate function based on argument
if [ "$1" == "start" ]; then
    usbAutorunStart
elif [ "$1" == "stop" ]; then
    usbAutorunStop
fi



