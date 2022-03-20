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
  echo "DATE: $DATE"
  echo "FILE: $FILE"
  #cat $FILE
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFPATH=$(echo "$HOME/.${NAME}_$NODEALIAS")
  NODEMNADDR=$(grep "masternodeaddr=" ~/.${NAME}_$NODEALIAS/${NAME}.conf | sed -e 's/\(^.*masternodeaddr=\)\(.*\)/\2/')
  NODEMNBIND=$(grep "bind=" ~/.${NAME}_$NODEALIAS/${NAME}.conf | sed -e 's/\(^.*bind=\)\(.*\)/\2/')
  NODEPRIVKEY=$(grep "masternodeprivkey=" ~/.${NAME}_$NODEALIAS/${NAME}.conf | sed -e 's/\(^.*masternodeprivkey=\)\(.*\)/\2/')
  #echo $NODEALIAS $NODEMNADDR $NODEPRIVKEY "txhash" "outputidx"

  #echo "NODE ALIAS: "$NODEALIAS
  echo "CONF FOLDER: "$NODECONFPATH
  echo "NODE ADDRESS: "$NODEMNADDR
  echo "NODE BIND: "$NODEMNBIND
  echo "NODE PRIVKEY: "$NODEPRIVKEY
  $FILE getinfo
done
