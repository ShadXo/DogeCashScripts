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
  echo "FILE "$FILE
  $FILE
done
