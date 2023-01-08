#!/bin/bash

# Execute getopt
ARGS=$(getopt -o "c:n:" -l "coin:,node:" -n "$0" -- "$@");

eval set -- "$ARGS";

while true; do
    case "$1" in
        -c |--coin)
            shift;
                    if [ -n "$1" ];
                    then
                        NAME="$1";
                        shift;
                    fi
            ;;
        -n |--node)
            shift;
                    if [ -n "$1" ];
                    then
                        ALIAS="$1";
                        shift;
                    fi
            ;;
        --)
            shift;
            break;
            ;;
    esac
done

# Check required arguments
if [ -z "$NAME" ]; then
    echo "You need to specify a coin, use -c or --coin to do so."
    echo "Example: $0 -c dogecash"
    exit 1
fi

if [ -z "$ALIAS" ]; then
  echo "You need to specify node alias, use -n or --node to do so."
  echo "Example: $0 -c dogecash -n mn1"
  exit -1
fi

for FILE in $(ls ~/bin/${NAME}d_$ALIAS.sh | sort -V); do
  echo "*******************************************"
  echo "FILE: $FILE"

  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFDIR=$(echo "$HOME/.${NAME}_$NODEALIAS")
  echo CONF DIR: $NODECONFDIR

  echo "Node $NODEALIAS will be deleted when this timer reaches 0"
  seconds=10
  date1=$(( $(date -u +%s) + seconds));
  echo "Press ctrl-c to stop"
  while [ "${date1}" -ge "$(date -u +%s)" ]
  do
    echo -ne "$(date -u --date @$(( date1 - $(date -u +%s) )) +%H:%M:%S)\r";
  done

  for (( ; ; ))
  do
    NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
    if [ -z "$NODEPID" ]; then
      echo ""
      break
    else
      #STOP
      echo "Stopping $NODEALIAS. Please wait ..."
      DAEMONSYSTEMDFILE="/etc/systemd/system/${NAME}_$NODEALIAS.service"
      if [[ ! -f "${DAEMONSYSTEMDFILE}" ]]; then
        echo "You need to update and run the main menu again (dogecash.sh). It will upgrade some things"
        ~/bin/${NAME}-cli_$NODEALIAS.sh stop
      else
        systemctl stop ${NAME}_$NODEALIAS.service
      fi
      #systemctl stop ${NAME}_$NODEALIAS.service
    fi
    #echo "Please wait ..."
    sleep 2 # wait 2 seconds
  done

  echo "Removing conf folder"
  rm -rdf $NODECONFDIR
  echo "Removing other node files"
  rm ~/bin/${NAME}-cli_$NODEALIAS.sh
  rm ~/bin/${NAME}d_$NODEALIAS.sh
  echo "Removing cron jobs"
  crontab -l | grep -v "@reboot sh ~/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  crontab -l | grep -v "@reboot sh /root/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  sudo service cron reload
  DAEMONSYSTEMDFILE="/etc/systemd/system/${NAME}_$NODEALIAS.service"
  if [[ ! -f "${DAEMONSYSTEMDFILE}" ]]; then
  echo "Removing systemd service"
  rm /etc/systemd/system/${NAME}_$NODEALIAS.service
  systemctl daemon-reload
  fi
  echo "Node $NODEALIAS removed"
done
