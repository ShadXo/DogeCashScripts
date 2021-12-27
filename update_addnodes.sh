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
  ALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')

  ~/bin/${NAME}-cli_$ALIAS.sh stop
  sleep 2 # wait 2 seconds

  ADDNODES=$( wget -4qO- -o- ${ADDNODESURL} | grep 'addnode=' | shuf )
  sed -i '/addnode\=/d' ~/.dogecash_$ALIAS/${NAME}.conf
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' ~/.dogecash_$ALIAS/${NAME}.conf # Remove empty lines at the end
  echo "${ADDNODES}" | tr " " "\\n" >> ~/.dogecash_$ALIAS/${NAME}.conf

  ~/bin/${NAME}d_$ALIAS.sh
done
