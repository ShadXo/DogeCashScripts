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

for FILE in $(ls ~/bin/${NAME}-cli_$ALIAS.sh | sort -V); do
  echo "*******************************************"
  echo "FILE: $FILE"
  
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')

  for (( ; ; ))
  do
    NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
    if [ -z "$NODEPID" ]; then
      echo ""
      break
    else
      #STOP
      echo "Stopping $NODEALIAS. Please wait ..."
      ~/bin/${NAME}-cli_$NODEALIAS.sh stop
      #systemctl stop ${NAME}d_$NODEALIAS.service
    fi
    #echo "Please wait ..."
    sleep 2 # wait 2 seconds
  done

done
