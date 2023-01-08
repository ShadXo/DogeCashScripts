#!/bin/bash

##
## Script sync wallet using current bootstrap
##

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

sudo apt-get install -y jq curl > /dev/null 2>&1

if [ -z "$ALIAS" ]; then
  echo "You need to specify node alias, use -n or --node to do so."
  echo "Example: $0 -c dogecash -n mn1"
  exit -1
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

if [ ! -f ~/bin/${NAME}d_$ALIAS.sh ]; then
    echo "Wallet $ALIAS not found!"
	exit -1
fi


for FILE in $(ls ~/bin/${NAME}d_$ALIAS.sh | sort -V); do
  echo "****************************************************************************"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE: $DATE"
  echo "FILE: $FILE"

  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFDIR=$(echo "$HOME/.${NAME}_$NODEALIAS")
  echo CONF DIR: $NODECONFDIR

  if [ ! -d $NODECONFDIR ]; then
	echo "Directory $NODECONFDIR not found!"
	exit -1
  fi

  for (( ; ; ))
  do
    sleep 2

	NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	echo "NODEPID="$NODEPID

	if [ -z "$NODEPID" ]; then
	  echo "Node $NODEALIAS is STOPPED can't check if synced!"
	fi

  WALLETLASTBLOCK=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockcount)
  WALLETBLOCKHASH=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockhash $WALLETLASTBLOCK)
  #WALLETBLOCKHASH=$(~/bin/${NAME}-cli_$NODEALIAS.sh getbestblockhash)

  if [ "$EXPLORERAPI" == "BLOCKBOOK" ]; then
    EXPLORERLASTBLOCK=$(curl -s4 $EXPLORER | jq -r ".backend.blocks")
    EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER | jq -r ".backend.bestBlockHash")
    EXPLORERWALLETVERSION=$(curl -s4 $EXPLORER | jq -r ".backend.version")
  elif [ "$EXPLORERAPI" == "DOGECASH" ]; then
    EXPLORERLASTBLOCK=$(curl -s4 $EXPLORER/info | jq -r ".result.blocks")
    EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER/info | jq -r ".result.bestblockhash")
    EXPLORERWALLETVERSION=0 # Can't get this from https://api2.dogecash.org
  elif [ "$EXPLORERAPI" == "DECENOMY" ]; then
    EXPLORERLASTBLOCK=$(curl -s4 $EXPLORER/blocks | jq -r ".response[0].height")
    EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER/blocks | jq -r ".response[0].blockhash")
    EXPLORERWALLETVERSION=$(curl -s4 $EXPLORER?expand=overview | jq -r ".response.overview.versions.wallet")
  elif [ "$EXPLORERAPI" == "IQUIDUS" ]; then
    EXPLORERLASTBLOCK=$(curl -s4 $EXPLORER/getblockcount)
    EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER/getblockhash?index=$EXPLORERLASTBLOCK | jq -r "")
    EXPLORERWALLETVERSION=$(curl -s4 $EXPLORER/getinfo | jq -r ".version")
  else
    echo "Unknown coin explorer, we can't compare blockhash or walletversion."
    break
  fi

  echo "WALLETLASTBLOCK="$WALLETLASTBLOCK
  echo "EXPLORERLASTBLOCK="$EXPLORERLASTBLOCK
  echo "WALLETBLOCKHASH="$WALLETBLOCKHASH
  echo "EXPLORERBLOCKHASH="$EXPLORERBLOCKHASH

  if [ "$WALLETBLOCKHASH" == "$EXPLORERBLOCKHASH" ]; then
    echo "Wallet $NODEALIAS is SYNCED!"
  elif [ "$BLOCKHASHCOINEXPLORER" == "Too" ]; then
    echo "COINEXPLORER Too many requests"
  else
    echo "Wallet $NODEALIAS is NOT SYNCED!"
  fi

  for (( ; ; ))
  do
    NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
    if [ -z "$NODEPID" ]; then
      echo ""
      break
    else
      #STOP
      echo "Stopping $NODEALIAS. Please wait ..."
      DAEMONSYSTEMDFILE="/etc/systemd/system/${NAME}_$NODEALIAS.service"
      if [[ ! -f "${DAEMONSYSTEMDFILE}" ]]; then
        echo "You need to update and run the main menu again (dogecash.sh). It will upgrade some things"
        ~/bin/${NAME}-cli_$NODEALIAS.sh stop
      else
        systemctl stop ${NAME}_$NODEALIAS.service
      fi
      #systemctl stop ${NAME}_$NODEALIAS.service
    fi
    #echo "Please wait ..."
    sleep 2 # wait 2 seconds
  done

  if [[ "$COUNTER" -gt 1 ]]; then
    kill -9 $NODEPID
  fi

	sleep 2 # wait 2 seconds
	NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	echo "NODEPID="$NODEPID

	if [ -z "$NODEPID" ]; then
	  echo "Node $NODEALIAS is STOPPED"
    # Create Temp folder
    mkdir -p $CONF_DIR_TMP
    cd $CONF_DIR_TMP

    echo "Downloading bootstrap"
    if [[ $BOOTSTRAPURL == *.tar.gz ]]; then
      wget ${BOOTSTRAPURL} -O bootstrap.tar.gz
      WGET=$?
    elif [[ $BOOTSTRAPURL == *.zip ]]; then
      wget ${BOOTSTRAPURL} -O bootstrap.zip
      WGET=$?
    fi

    if [ $WGET -eq 0 ]; then
      echo "Downloading bootstrap successful"
      #cd ~
      cd $NODECONFDIR
      echo "Copying BLOCKCHAIN from bootstrap without conf files"
      rm -R ./database &> /dev/null
      rm -R ./blocks	&> /dev/null
      rm -R ./sporks &> /dev/null
      rm -R ./chainstate &> /dev/null

      if [[ $BOOTSTRAPURL == *.tar.gz ]]; then
        #mv $CONF_DIR_TMP/blocks_n_chains.tar.gz .
        #tar -xvzf blocks_n_chains.tar.gz
        tar -xvzf $CONF_DIR_TMP/bootstrap.tar.gz -C $NODECONFDIR --exclude="*.conf"
        #rm ./blocks_n_chains.tar.gz
      elif [[ $BOOTSTRAPURL == *.zip ]]; then
        #mv $CONF_DIR_TMP/bootstrap.zip .
        #unzip bootstrap.zip
        unzip $CONF_DIR_TMP/bootstrap.zip -d $NODECONFDIR -x "*.conf"
        #rm ./bootstrap.zip
      fi
    fi

    NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
    if [ -z "$NODEPID" ]; then
      # start wallet
      echo "Starting $NODEALIAS."
      DAEMONSYSTEMDFILE="/etc/systemd/system/${NAME}_$NODEALIAS.service"
      if [[ ! -f "${DAEMONSYSTEMDFILE}" ]]; then
        ~/bin/${NAME}d_$NODEALIAS.sh
      else
        systemctl start ${NAME}_$NODEALIAS.service
      fi
      #systemctl start ${NAME}_$NODEALIAS.service
      sleep 2 # wait 2 seconds
    fi

	  break
	else
	  echo "Node $NODEALIAS still running!"
	fi

	COUNTER=$[COUNTER + 1]
	echo COUNTER: $COUNTER
	if [[ "$COUNTER" -gt 9 ]]; then
	  break
	fi
  done
done
