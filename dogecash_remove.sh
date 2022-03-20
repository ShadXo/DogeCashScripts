#!/bin/bash

NAME="dogecash"
PARAM1=$*
PARAM1=${PARAM1,,}

if [ -z "$PARAM1" ]; then
  echo "Need to specify node alias!"
  exit -1
fi

for FILE in $(ls ~/bin/${NAME}d_$PARAM1.sh | sort -V); do
  echo "*******************************************"
  echo "FILE: $FILE"
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFPATH=$(echo "$HOME/.${NAME}_$NODEALIAS")
  echo CONF DIR: $NODECONFPATH

  echo "Node $NODEALIAS will be deleted when this timer reaches 0"
  seconds=10
  date1=$(( $(date -u +%s) + seconds));
  echo "Press ctrl-c to stop"
  while [ "${date1}" -ge "$(date -u +%s)" ]
  do
    echo -ne "$(date -u --date @$(( date1 - $(date -u +%s) )) +%H:%M:%S)\r";
  done

  ~/bin/${NAME}-cli_$NODEALIAS.sh stop
  sleep 2 # wait 2 seconds
  echo "Removing conf folder"
  rm -rdf $NODECONFPATH
  echo "Removing other node files"
  rm ~/bin/${NAME}-cli_$NODEALIAS.sh
  rm ~/bin/${NAME}d_$NODEALIAS.sh
  echo "Removing cron jobs"
  crontab -l | grep -v "@reboot sh ~/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  crontab -l | grep -v "@reboot sh /root/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  sudo service cron reload
  echo "Node $NODEALIAS removed"
done
