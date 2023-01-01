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
  sleep 2
  echo "****************************************************************************"
  echo "FILE: $FILE"

  #ALIASSTARTPOS=$(echo $FILE | grep -b -o _)
  #ALIASLENGTH=$(echo $FILE | grep -b -o .sh)
  #ALIASSTARTPOS_1=$(echo ${ALIASSTARTPOS:0:2})
  #ALIASSTARTPOS_1=$[ALIASSTARTPOS_1 + 1]
  #NODEALIAS=$(echo ${FILE:ALIASSTARTPOS_1:${ALIASLENGTH:0:2}-ALIASSTARTPOS_1})
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')


  NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "NODEPID="$NODEPID

  if [ -z "$NODEPID" ]; then
    echo "Node $NODEALIAS is STOPPED can't check if synced!"
  else

	  LASTBLOCK=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockcount)
	  GETBLOCKHASH=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockhash $LASTBLOCK)

    #BLOCKHASHCOINEXPLORER=$(curl -s4 https://explorer.dogec.io/api/blocks | jq -r ".backend.bestblockhash")
    BLOCKHASHCOINEXPLORER=$(curl -s4 https://dogec.flitswallet.app/api/blocks | jq -r ".backend.bestBlockHash")
    #BLOCKHASHCOINEXPLORER=$(curl -s4 https://api2.dogecash.org/info | jq -r ".result.bestblockhash")

    #LATESTWALLETVERSION=$(curl -s4 https://https://explorer.decenomy.net/coreapi/v1/coins/DOGECASH?expand=overview | jq -r ".response.versions.wallet")
    #LATESTWALLETVERSION=$(curl -s4 https://dogec.flitswallet.app/api/blocks | jq -r ".backend.version")

	  WALLETVERSION=$(~/bin/${NAME}-cli_$NODEALIAS.sh getinfo | grep -i \"version\")
	  WALLETVERSION=$(echo $WALLETVERSION | tr , " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr '"' " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr 'version : ' " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr -d ' ' )

	  if ! [ "$WALLETVERSION" == "5040400" ]; then
	     echo "!!!Your wallet $NODEALIAS is OUTDATED!!!"
	  fi

	  echo "LASTBLOCK="$LASTBLOCK
	  echo "GETBLOCKHASH="$GETBLOCKHASH
	  echo "BLOCKHASHCOINEXPLORER="$BLOCKHASHCOINEXPLORER
	  echo "WALLETVERSION="$WALLETVERSION

	  if [ "$GETBLOCKHASH" == "$BLOCKHASHCOINEXPLORER" ]; then
		echo "Wallet $NODEALIAS is SYNCED!"
	  else
		if [ "$BLOCKHASHCOINEXPLORER" == "Too" ]; then
		   echo "COINEXPLORER Too many requests"
		else
		   echo "Wallet $NODEALIAS is NOT SYNCED!"
		fi
	  fi
  fi
done
