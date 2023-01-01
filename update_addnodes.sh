#!/bin/bash

#ADDNODESURL="https://www.dropbox.com/s/s0pdil1rehsy4fu/peers.txt?dl=1"
ADDNODESURL="https://api.dogecash.org/api/v1/network/peers"

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
  echo "FILE: $FILE"
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')

  ~/bin/${NAME}-cli_$NODEALIAS.sh stop
  sleep 2 # wait 2 seconds

  #ADDNODES=$( wget -4qO- -o- ${ADDNODESURL} | grep 'addnode=' | shuf ) # If using Dropbox link
  ADDNODES=$( curl -s4 ${ADDNODESURL} | jq -r ".result" | jq -r '.[]' )
  sed -i '/addnode=/d' ~/.${NAME}_$NODEALIAS/${NAME}.conf # Remove addnode lines from config
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' ~/.${NAME}_$NODEALIAS/${NAME}.conf # Remove empty lines at the end
  #echo "${ADDNODES}" | tr " " "\\n" >> ~/.${NAME}_$NODEALIAS/${NAME}.conf # If using Dropbox link
  echo "${ADDNODES}" | sed "s/^/addnode=/g" >> ~/.${NAME}_$NODEALIAS/${NAME}.conf
  sed -i '/addnode=localhost:56740/d' ~/.${NAME}_$NODEALIAS/${NAME}.conf # Remove addnode=localhost:56740 line from config, api is giving localhost back as a peer

  ~/bin/${NAME}d_$NODEALIAS.sh
done
