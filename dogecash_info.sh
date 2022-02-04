#!/bin/bash

NAME="dogecash"
PARAM1=$*

if [ -z "$PARAM1" ]; then
  PARAM1="*"
else
  PARAM1=${PARAM1,,}
fi

for FILE in $(ls ~/bin/${NAME}-cli_$PARAM1.sh | sort -V); do
  echo "*******************************************"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE="$DATE
  echo "FILE: "$FILE
  #cat $FILE
  DOGECASHNAME=$(echo $FILE | awk -F'[_.]' '{print $2}')
  DOGECASHCONFPATH=$(echo "$HOME/.${NAME}_$DOGECASHNAME")
  DOGECASHMNADDR=$(grep "masternodeaddr=" ~/.${NAME}_$DOGECASHNAME/${NAME}.conf | sed -e 's/\(^.*masternodeaddr=\)\(.*\)/\2/')
  DOGECASHMNBIND=$(grep "bind=" ~/.${NAME}_$DOGECASHNAME/${NAME}.conf | sed -e 's/\(^.*bind=\)\(.*\)/\2/')
  DOGECASHPRIVKEY=$(grep "masternodeprivkey=" ~/.${NAME}_$DOGECASHNAME/${NAME}.conf | sed -e 's/\(^.*masternodeprivkey=\)\(.*\)/\2/')
  #echo $DOGECASHNAME $DOGECASHMNADDR $DOGECASHPRIVKEY "txhash" "outputidx"

  #echo "NODE ALIAS: "$DOGECASHNAME
  echo "CONF FOLDER: "$DOGECASHCONFPATH
  echo "NODE ADDRESS: "$DOGECASHMNADDR
  echo "NODE BIND: "$DOGECASHMNBIND
  echo "NODE PRIVKEY: "$DOGECASHPRIVKEY
  $FILE getinfo
done
