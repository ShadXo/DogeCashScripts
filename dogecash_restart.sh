#!/bin/bash

NAME="dogecash"
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

  DOGECASHPID=`ps -ef | grep -i -w dogecash_$ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "DOGECASHPID="$DOGECASHPID

  if [ "$DOGECASHPID" ]; then
  ~/bin/${NAME}-cli_$ALIAS.sh stop
  sleep 2 # wait 2 seconds
  fi

  $FILE
  sleep 3 # wait 3 seconds

  DOGECASHPID=`ps -ef | grep -i -w dogecash_$ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "DOGECASHPID="$DOGECASHPID
done
