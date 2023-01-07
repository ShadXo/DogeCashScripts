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
if [ -z "$NAME" ]
then
    echo "You need to specify a coin, use -c or --coin to do so."
    echo "Example: $0 -c dogecash"
    exit 1
fi

if [ -z "$ALIAS" ]; then
  ALIAS="*"
else
  ALIAS=${ALIAS,,}
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

echo ""
echo "Upgrade service started"
echo "Checking for possible upgrades"

: << "DAEMON"
if [[ $(ls /usr/bin/${NAME}* 2> /dev/null) ]]; then
  echo "Moving daemon, cli, and some other files to the correct location"
  mv /usr/bin/${NAME}* /usr/local/bin
fi
DAEMON

: << "SERVICE"
echo "Upgrading node to use a service"
for FILE in $(ls ~/bin/${NAME}d_$ALIAS.sh | sort -V); do
  echo "*******************************************"
  echo "FILE: $FILE"

  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFDIR=$(echo "$HOME/.${NAME}_$NODEALIAS")
  echo CONF DIR: $NODECONFDIR

  DAEMONSYSTEMDFILE="/etc/systemd/system/${NAME}_$NODEALIAS.service"
  if [[ $(ls ~/bin/${NAME}d_$NODEALIAS.sh) ]] && [[ ! -f "${DAEMONSYSTEMDFILE}" ]]; then

  echo "Node $NODEALIAS will be upgraded when this timer reaches 0"
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
      ~/bin/${NAME}-cli_$NODEALIAS.sh stop
      #systemctl stop ${NAME}_$NODEALIAS.service
    fi
    #echo "Please wait ..."
    sleep 2 # wait 2 seconds
  done

  #echo "Removing other node files?????????????????????? NEEDS TESTING"
  #rm ~/bin/${NAME}-cli_$NODEALIAS.sh
  #rm ~/bin/${NAME}d_$NODEALIAS.sh

  echo "Removing cron jobs"
  crontab -l | grep -v "@reboot sh ~/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  crontab -l | grep -v "@reboot sh /root/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  service cron reload

  echo "Creating systemd service for ${NAME}_$NODEALIAS"
cat << EOF > /etc/systemd/system/${NAME}_$NODEALIAS.service
[Unit]
Description=DogeCash Service for $NODEALIAS
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=${NAME}d -daemon -conf=$NODECONFDIR/${NAME}.conf -datadir=$NODECONFDIR
ExecStop=${NAME}-cli -conf=$NODECONFDIR/${NAME}.conf -datadir=$NODECONFDIR stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
sleep 2 # wait 2 seconds
systemctl enable ${NAME}_$NODEALIAS.service
systemctl start ${NAME}_$NODEALIAS.service
#systemctl enable --now ${NAME}_$NODEALIAS.service

  echo "Node $NODEALIAS upgrade done"
else
  echo "Node $NODEALIAS already upgraded"
fi
done
SERVICE

echo "Upgrade service complete"
