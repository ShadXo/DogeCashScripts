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
  sleep 2
  echo "****************************************************************************"
  echo "FILE: $FILE"

  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')

  NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "NODEPID="$NODEPID

  if [ -z "$NODEPID" ]; then
    echo "Node $NODEALIAS is STOPPED can't check if synced!"
  else

	  WALLETLASTBLOCK=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockcount)
	  WALLETBLOCKHASH=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockhash $WALLETLASTBLOCK)
    #WALLETBLOCKHASH=$(~/bin/${NAME}-cli_$NODEALIAS.sh getbestblockhash)

    if [ "$EXPLORERAPI" == "BLOCKBOOK" ]; then
      EXPLORERLASTBLOCK=$(curl -s $EXPLORER | jq -r ".backend.blocks")
      EXPLORERBLOCKHASH=$(curl -s $EXPLORER | jq -r ".backend.bestBlockHash")
      EXPLORERWALLETVERSION=$(curl -s $EXPLORER | jq -r ".backend.version")
    elif [ "$EXPLORERAPI" == "DOGECASH" ]; then
      #BLOCKHASHCOINEXPLORER=$(curl -s https://explorer.dogec.io/api/blocks | jq -r ".backend.bestblockhash")
      #BLOCKHASHCOINEXPLORER=$(curl -s https://dogec.flitswallet.app/api/blocks | jq -r ".backend.bestBlockHash")
      #BLOCKHASHCOINEXPLORER=$(curl -s https://api2.dogecash.org/info | jq -r ".result.bestblockhash")
      #LATESTWALLETVERSION=$(curl -s https://dogec.flitswallet.app/api/blocks | jq -r ".backend.version")
      EXPLORERLASTBLOCK=$(curl -s $EXPLORER/info | jq -r ".result.blocks")
      EXPLORERBLOCKHASH=$(curl -s $EXPLORER/info | jq -r ".result.bestblockhash")
      EXPLORERWALLETVERSION=0 # Can't get this from https://api2.dogecash.org
    elif [ "$EXPLORERAPI" == "DECENOMY" ]; then
      #BLOCKHASHCOINEXPLORER=$(curl -s https://explorer.trittium.net/coreapi/v1/coins/MONK/blocks | jq -r ".response[0].blockhash")
      #LATESTWALLETVERSION=$(curl -s https://https://explorer.decenomy.net/coreapi/v1/coins/DOGECASH?expand=overview | jq -r ".response.versions.wallet")
      EXPLORERLASTBLOCK=$(curl -s $EXPLORER/blocks | jq -r ".response[0].height")
      #EXPLORERLASTBLOCK=$(curl -s $EXPLORER | jq -r ".response.bestblockheight")
      EXPLORERBLOCKHASH=$(curl -s $EXPLORER/blocks | jq -r ".response[0].blockhash")
      EXPLORERWALLETVERSION=$(curl -s $EXPLORER?expand=overview | jq -r ".response.overview.versions.wallet")
    elif [ "$EXPLORERAPI" == "IQUIDUS" ]; then
      EXPLORERLASTBLOCK=$(curl -s $EXPLORER/getblockcount)
      EXPLORERBLOCKHASH=$(curl -s $EXPLORER/getblockhash?index=$EXPLORERLASTBLOCK)
      EXPLORERWALLETVERSION=$(curl -s $EXPLORER/getinfo | jq -r ".version")
    elif [ "$EXPLORERAPI" == "IQUIDUS-OLD" ]; then
      EXPLORERLASTBLOCK=$(curl -s $EXPLORER/getblockcount)
      EXPLORERBLOCKHASH=$(curl -s $EXPLORER/getblockhash?index=$EXPLORERLASTBLOCK | sed 's/"//g')
      EXPLORERWALLETVERSION=$(curl -s $EXPLORER/getinfo | jq -r ".version")
    else
      echo "Unknown coin explorer, we can't compare blockhash or walletversion."
      break
    fi

    WALLETVERSION=$(~/bin/${NAME}-cli_$NODEALIAS.sh getinfo | jq ".version")

	  if [ "$WALLETVERSION" -lt "$EXPLORERWALLETVERSION" ]; then
	     echo "!!!Your wallet $NODEALIAS is OUTDATED!!!"
	  fi

	  echo "WALLETLASTBLOCK="$WALLETLASTBLOCK
    echo "EXPLORERLASTBLOCK="$EXPLORERLASTBLOCK
	  echo "WALLETBLOCKHASH="$WALLETBLOCKHASH
	  echo "EXPLORERBLOCKHASH="$EXPLORERBLOCKHASH
	  echo "WALLETVERSION="$WALLETVERSION
    echo "EXPLORERWALLETVERSION="$EXPLORERWALLETVERSION

	  if [ "$WALLETBLOCKHASH" == "$EXPLORERBLOCKHASH" ]; then
      echo "Wallet $NODEALIAS is SYNCED!"
	  elif [ "$BLOCKHASHCOINEXPLORER" == "Too" ]; then
      echo "COINEXPLORER Too many requests"
		else
      echo "Wallet $NODEALIAS is NOT SYNCED!"
		fi
  fi
done
