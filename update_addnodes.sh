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

# GET CONFIGURATION
#declare -r SCRIPTPATH=$( cd $(dirname ${BASH_SOURCE[0]}) > /dev/null; pwd -P )
#SETUP_CONF_FILE="${SCRIPTPATH}/coins/${NAME}/${NAME}.env"
SETUP_CONF_FILE="./coins/${NAME}/${NAME}.env"
#if [ `wget --spider -q https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/coins/${NAME}/${NAME}.env` ]; then
mkdir -p ./coins/${NAME}
wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/coins/${NAME}/${NAME}.env -O $SETUP_CONF_FILE > /dev/null 2>&1
chmod 777 $SETUP_CONF_FILE &> /dev/null
#dos2unix $SETUP_CONF_FILE > /dev/null 2>&1
#fi

if [ -f ${SETUP_CONF_FILE} ] && [ -s ${SETUP_CONF_FILE} ]; then
  echo "Using setup env file: ${SETUP_CONF_FILE}"
  source "${SETUP_CONF_FILE}"
else
  echo "No setup env file found, create one at the following location: ./coins/${NAME}/${NAME}.env"
  exit 1
fi

for FILE in $(ls ~/bin/${NAME}d_$ALIAS.sh | sort -V); do
  echo "*******************************************"
  echo "FILE: $FILE"
  
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFDIR=$(echo "$HOME/.${NAME}_$NODEALIAS")

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

  if [ -z "$PID" ] && [ "$ADDNODESURL" ]; then
    if [ "$EXPLORERAPI" == "BLOCKBOOK" ]; then
      if [ "$NAME" == "dogecash" ]; then
        ADDNODES=$( curl -s4 https://api.dogecash.org/api/v1/network/peers | jq -r ".result" | jq -r '.[]' )
      else
        echo "Not tried it yet"
      fi
    elif [ "$EXPLORERAPI" == "DOGECASH" ]; then
      #ADDNODES=$( wget -4qO- -o- ${ADDNODESURL} | grep 'addnode=' | shuf ) # If using Dropbox link
      ADDNODES=$( curl -s4 ${ADDNODESURL} | jq -r ".result" | jq -r '.[]' )
    elif [ "$EXPLORERAPI" == "DECENOMY" ]; then
      ADDNODES=$( curl -s4 ${ADDNODESURL} | jq -r --arg PORT "$PORT" '.response | .[].addr | select( . | contains($PORT))' )
    else
      echo "Unknown coin explorer, we will continue without addnodes."
      break
    fi

    sed -i '/addnode=/d' $NODECONFDIR/${NAME}.conf
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' $NODECONFDIR/${NAME}.conf # Remove empty lines at the end
    #echo "${ADDNODES}" | tr " " "\\n" >> $CONF_DIR/${NAME}.conf # If using Dropbox link
    echo "${ADDNODES}" | sed "s/^/addnode=/g" >> $NODECONFDIR/${NAME}.conf
    sed -i '/addnode=localhost:56740/d' $NODECONFDIR/${NAME}.conf # Remove addnode=localhost:56740 line from config, api is giving localhost back as a peer
  fi

  NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  if [ -z "$NODEPID" ]; then
    # start wallet
    echo "Starting $NODEALIAS."
    ~/bin/${NAME}d_$NODEALIAS.sh
    #systemctl start ${NAME}d_$NODEALIAS.service
    sleep 2 # wait 2 seconds
  fi
done
