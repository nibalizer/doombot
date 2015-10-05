#!/usr/bin/env bash

started=""
times=1
botfile=botttttt
puppetconf_pass=`cat .password`
echo $puppetconf_pass
rm $botfile
mkfifo $botfile
tail -f $botfile | openssl s_client -CAfile ca.pem -connect puppetconf.irc.slack.com:6697 | while true ; do
    if [ -z $started ] ; then
        echo "PASS $puppetconf_pass" > $botfile
        echo "USER doom 9 doom :" > $botfile
        echo "NICK doom" > $botfile
        echo "JOIN #test" > $botfile
        echo "JOIN #random" > $botfile
        echo "PART #general" > $botfile
        started="yes"
    fi
    read irc
    case `echo $irc | cut -d " " -f 1` in
         "PING") echo "PONG `hostname`" > $botfile
            ;;
    esac

    chan=`echo $irc | cut -d ' ' -f 3`
    barf=`echo $irc | cut -d ' ' -f 1-3`
    cmd=`echo ${irc##$barf :}|cut -d ' ' -f 1|tr -d "\r\n"`
    args=`echo ${irc##$barf :$cmd}|tr -d "\r\n"`
    nick="${irc%%!*}";nick="${nick#:}"
    if [ "`echo $cmd | cut -c1`" == "/" ] ; then
    echo "Got command $cmd from channel $chan with arguments $args"
    fi

case $cmd in
        #"!add") line="$args $line" ;;
        #"!list") echo "PRIVMSG $chan :$line" >> $botfile ;;
        "/birthday") echo "PRIVMSG $chan :$birthday" >> $botfile ;;
        "!doom")
          echo -n "PRIVMSG $chan :" >> $botfile
          cat doom.txt | sort -R | head -n 1 >> $botfile
        ;;
    esac
    echo $irc
done
