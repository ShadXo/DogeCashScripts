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
  echo "DATE="$DATE
  echo "FILE: "$FILE
  #cat $FILE
  DOGECASHSTARTPOS=$(echo $FILE | grep -b -o _)
  DOGECASHLENGTH=$(echo $FILE | grep -b -o .sh)
  # echo ${DOGECASHSTARTPOS:0:2}
  #DOGECASHSTARTPOS_1=$(echo ${DOGECASHSTARTPOS:0:2})
  #DOGECASHSTARTPOS_1=$[DOGECASHSTARTPOS_1 + 1]
  #DOGECASHNAME=$(echo ${FILE:DOGECASHSTARTPOS_1:${DOGECASHLENGTH:0:2}-DOGECASHSTARTPOS_1})
  DOGECASHNAME=$(echo $FILE | awk -F'[_.]' '{print $2}')
  DOGECASHCONFPATH=$(echo "$HOME/.${NAME}_$DOGECASHNAME")
  # echo $DOGECASHSTARTPOS_1
  # echo ${DOGECASHLENGTH:0:2}
  echo "NODE ALIAS: "$DOGECASHNAME
  echo "CONF FOLDER: "$DOGECASHCONFPATH
done
