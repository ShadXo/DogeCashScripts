#!/bin/bash

NAME="dogecash"
ADDNODESURL="https://www.dropbox.com/s/s0pdil1rehsy4fu/peers.txt?dl=1"
PARAM1=$*

if [ -z "$PARAM1" ]; then
  PARAM1="*"
else
  PARAM1=${PARAM1,,}
fi

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  echo "*******************************************"
  echo "FILE "$FILE
  ~/bin/${NAME}-cli_$PARAM1.sh stop
  sleep 2 # wait 2 seconds

  ADDNODES=$( wget -4qO- -o- ${ADDNODESURL} | grep 'addnode=' | shuf )
  sed -i '/addnode\=/d' ~/.dogecash_$PARAM1/${NAME}.conf
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' ~/.dogecash_$PARAM1/${NAME}.conf # Remove empty lines at the end
  echo "${ADDNODES}" | tr " " "\\n" >> ~/.dogecash_$PARAM1/${NAME}.conf

  ~/bin/${NAME}d_$PARAM1.sh
done
