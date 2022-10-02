#!/bin/bash

NAME="dogecash"
PARAM1=$*

if [ -z "$PARAM1" ]; then
  PARAM1="*"
else
  PARAM1=${PARAM1,,}
fi

for FILE in $(ls ~/bin/${NAME}d_$PARAM1.sh | sort -V); do
  echo "*******************************************"
  echo "FILE: $FILE"
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFPATH=$(echo "$HOME/.${NAME}_$NODEALIAS")
  echo CONF DIR: $NODECONFPATH

  echo "Node $NODEALIAS will be upgraded when this timer reaches 0"
  seconds=10
  date1=$(( $(date -u +%s) + seconds));
  echo "Press ctrl-c to stop"
  while [ "${date1}" -ge "$(date -u +%s)" ]
  do
    echo -ne "$(date -u --date @$(( date1 - $(date -u +%s) )) +%H:%M:%S)\r";
  done

  DAEMONSYSTEMDFILE="/etc/systemd/system/${NAME}d_$NODEALIAS.service"
  if [[ ! -f "${DAEMONSYSTEMDFILE}" ]]; then

  ~/bin/${NAME}-cli_$NODEALIAS.sh stop
  sleep 2 # wait 2 seconds

  echo "Removing other node files?????????????????????? NEEDS TESTING"
  rm ~/bin/${NAME}-cli_$NODEALIAS.sh
  rm ~/bin/${NAME}d_$NODEALIAS.sh

  echo "Removing cron jobs"
  crontab -l | grep -v "@reboot sh ~/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  crontab -l | grep -v "@reboot sh /root/bin/${NAME}d_$NODEALIAS.sh" | crontab -
  sudo service cron reload

  echo "Creating systemd service for ${NAME}d_$NODEALIAS"
  function configure_systemd {
cat << EOF > /etc/systemd/system/${NAME}d_$NODEALIAS.service
[Unit]
Description=DogeCash Service for $NODEALIAS
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR
ExecStop=-${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR stop
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
sleep 2
systemctl enable ${NAME}d_$NODEALIAS.service
systemctl start ${NAME}d_$NODEALIAS.service
}
  echo "Node $NODEALIAS upgrade done"
else
  echo "Node $NODEALIAS already upgraded"
fi
done
