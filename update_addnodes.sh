#!/bin/bash

NAME="dogecash"
#ADDNODESURL="https://www.dropbox.com/s/s0pdil1rehsy4fu/peers.txt?dl=1"
ADDNODESURL="https://api.dogecash.org/api/v1/network/peers"
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

  ~/bin/${NAME}-cli_$NODEALIAS.sh stop
  sleep 2 # wait 2 seconds

  #ADDNODES=$( wget -4qO- -o- ${ADDNODESURL} | grep 'addnode=' | shuf ) # If using Dropbox link
  ADDNODES=$( curl -s4 ${ADDNODESURL} | jq -r ".result" | jq -r '.[]' )
  sed -i '/addnode\=/d' ~/.${NAME}_$NODEALIAS/${NAME}.conf # Remove addnode lines from config
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' ~/.${NAME}_$NODEALIAS/${NAME}.conf # Remove empty lines at the end
  #echo "${ADDNODES}" | tr " " "\\n" >> ~/.${NAME}_$NODEALIAS/${NAME}.conf # If using Dropbox link
  echo "${ADDNODES}" | sed "s/^/addnode=/g" >> ~/.${NAME}_$NODEALIAS/${NAME}.conf

  ~/bin/${NAME}d_$NODEALIAS.sh
done
