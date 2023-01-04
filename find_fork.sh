#/bin/bash

#INCREMENT=$3
INCREMENT=1

# Execute getopt
ARGS=$(getopt -o "c:n:b:" -l "coin:,node:,block:" -n "$0" -- "$@");

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
        -b |--block)
            shift;
                    if [ -n "$1" ];
                    then
                      BLOCK="$1";
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
  echo "You need to specify node alias, use -n or --node to do so."
  exit -1
fi

if [ -z "$BLOCK" ]; then
  echo "You need to specify a starting block, use -b or --block to do so"
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

for (( ; ; ))
do
  echo "Running check on $ALIAS"
  echo "Starting from block $BLOCK"

	for (( ; ; ))
	do
		for FILE in $(ls ~/bin/${NAME}-cli_$ALIAS.sh | sort -V); do
      echo "*******************************************"
      echo "Checking block $BLOCK"
			#echo "FILE: $FILE"

      if [ "$EXPLORERAPI" == "BLOCKBOOK" ]; then
        EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER/block/$BLOCK | jq -r ".hash")
      elif [ "$EXPLORERAPI" == "DOGECASH" ]; then
        EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER/height/$BLOCK | jq -r ".result.hash")
      elif [ "$EXPLORERAPI" == "DECENOMY" ]; then
        EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER/blocks | jq -r ".response[0].blockhash")
      elif [ "$EXPLORERAPI" == "IQUIDUS" ]; then
        EXPLORERBLOCKHASH=$(curl -s4 $EXPLORER/getblockhash?index=$BLOCK | jq -r "")
      else
        echo "Unknown coin explorer, we can't compare blockhash."
        break
      fi

      if [ -z "$EXPLORERBLOCKHASH" ]; then
			  break 2
			fi
      if [ "$EXPLORERBLOCKHASH" == null ]; then
        echo "NO FORK FOUND"
			  break 2
			fi

      #WALLETBLOCKHASH=$(~/bin/${NAME}-cli_$ALIAS.sh getblockhash $BLOCK)
      WALLETBLOCKHASH=$($FILE getblockhash $BLOCK)
      if [ -z "$WALLETBLOCKHASH" ]; then
			  break 2
			fi

			echo "EXPLORERBLOCKHASH=$EXPLORERBLOCKHASH"
      echo "WALLETBLOCKHASH=$WALLETBLOCKHASH"
		done

		if [ "$WALLETBLOCKHASH" != "$EXPLORERBLOCKHASH" ]; then
		  echo "FORK FOUND ON BLOCK $BLOCK !!!!"
		  break
		fi

		BLOCK=$[BLOCK + $INCREMENT]
	done

	BLOCK=$[BLOCK - $INCREMENT]
	INCREMENT=$[INCREMENT / 10]

    if [[ "$INCREMENT" -eq 0 ]]; then
	  break
	fi

    if [[ "$INCREMENT" -lt 1 ]]; then
	  break
	fi
done
