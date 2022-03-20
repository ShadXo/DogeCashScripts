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

  NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "NODEPID="$NODEPID

  if [ "$NODEPID" ]; then
  ~/bin/${NAME}-cli_$NODEALIAS.sh stop
  sleep 2 # wait 2 seconds
  fi

  $FILE
  sleep 3 # wait 3 seconds

  NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "NODEPID="$NODEPID
done
