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
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE: $DATE"
  echo "FILE: $FILE"
  #cat $FILE
  #ALIASSTARTPOS=$(echo $FILE | grep -b -o _)
  #ALIASLENGTH=$(echo $FILE | grep -b -o .sh)
  # echo ${ALIASSTARTPOS:0:2}
  #ALIASSTARTPOS_1=$(echo ${ALIASSTARTPOS:0:2})
  #ALIASSTARTPOS_1=$[ALIASSTARTPOS_1 + 1]
  #NODEALIAS=$(echo ${FILE:ALIASSTARTPOS_1:${ALIASLENGTH:0:2}-ALIASSTARTPOS_1})
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFPATH=$(echo "$HOME/.${NAME}_$NODEALIAS")
  # echo $ALIASSTARTPOS_1
  # echo ${ALIASLENGTH:0:2}
  echo "NODE ALIAS: "$NODEALIAS
  echo "CONF FOLDER: "$NODECONFPATH
done
