#!/bin/bash

NAME="dogecash"
PARAM1=$*

if [ -z "$PARAM1" ]; then
  PARAM1="*"
else
  PARAM1=${PARAM1,,}
fi

sudo apt-get install -y jq curl > /dev/null 2>&1

for FILE in $(ls ~/bin/${NAME}d_$PARAM1.sh | sort -V); do
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
