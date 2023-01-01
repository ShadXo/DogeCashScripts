#!/bin/bash

# Execute getopt
ARGS=$(getopt -o "c:n:" -l "coin:,node:" -n "$0" -- "$@");

eval set -- "$ARGS";

while true; do
    case "$1" in
        -c |--coin)
            shift;
                    if [ -n "$1" ];
                    then
                        NAME="$1";
                        shift;
                    fi
            ;;
        -n |--node)
            shift;
                    if [ -n "$1" ];
                    then
                        ALIAS="$1";
                        shift;
                    fi
            ;;
        --)
            shift;
            break;
            ;;
    esac
done

# Check required arguments
if [ -z "$NAME" ]; then
    echo "You need to specify a coin, use -c or --coin to do so."
    echo "Example: $0 -c dogecash"
    exit 1
fi

if [ -z "$ALIAS" ]; then
  ALIAS="*"
else
  ALIAS=${ALIAS,,}
fi

for FILE in $(ls ~/bin/${NAME}d_$ALIAS.sh | sort -V); do
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
