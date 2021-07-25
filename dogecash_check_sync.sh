#!/bin/bash

NAME="dogecash"
PARAM1=$*

if [ -z "$PARAM1" ]; then
  PARAM1="*"
else
  PARAM1=${PARAM1,,}
fi

sudo apt-get install -y jq > /dev/null 2>&1

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  sleep 2
  echo "****************************************************************************"
  echo FILE: " $FILE"

  DOGECASHSTARTPOS=$(echo $FILE | grep -b -o _)
  DOGECASHLENGTH=$(echo $FILE | grep -b -o .sh)
  #DOGECASHSTARTPOS_1=$(echo ${DOGECASHSTARTPOS:0:2})
  #DOGECASHSTARTPOS_1=$[DOGECASHSTARTPOS_1 + 1]
  #DOGECASHNAME=$(echo ${FILE:DOGECASHSTARTPOS_1:${DOGECASHLENGTH:0:2}-DOGECASHSTARTPOS_1})
  DOGECASHNAME=$(echo $FILE | awk -F'[_.]' '{print $2}')


  DOGECASHPID=`ps -ef | grep -i $DOGECASHNAME | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "DOGECASHPID="$DOGECASHPID

  if [ -z "$DOGECASHPID" ]; then
    echo "DOGECASH $DOGECASHNAME is STOPPED can't check if synced!"
  else

	  LASTBLOCK=$(~/bin/${NAME}-cli_$DOGECASHNAME.sh getblockcount)
	  GETBLOCKHASH=$(~/bin/${NAME}-cli_$DOGECASHNAME.sh getblockhash $LASTBLOCK)

	  #LASTBLOCKCOINEXPLORERDOGECASH=$(curl -s4 https://www.coinexplorer.net/api/DOGECASH/block/latest)
	  #BLOCKHASHCOINEXPLORERDOGECASH=', ' read -r -a array <<< $LASTBLOCKCOINEXPLORERDOGECASH
	  #BLOCKHASHCOINEXPLORERDOGECASH=${array[6]}
	  #BLOCKHASHCOINEXPLORERDOGECASH=$(echo $BLOCKHASHCOINEXPLORERDOGECASH | tr , " ")
	  #BLOCKHASHCOINEXPLORERDOGECASH=$(echo $BLOCKHASHCOINEXPLORERDOGECASH | tr '"' " ")
	  #BLOCKHASHCOINEXPLORERDOGECASH="$(echo -e "${BLOCKHASHCOINEXPLORERDOGECASH}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	  #BLOCKHASHCOINEXPLORERDOGECASH=$(curl -s4 https://www.coinexplorer.net/api/DOGECASH/block/latest | jq -r ".result.hash")

    BLOCKHASHCOINEXPLORERDOGECASH=$(curl -s4 https://explorer.dogec.io/api/blocks | jq -r ".backend.bestblockhash")

    #LATESTWALLETVERSION=$(curl -s4 https://https://explorer.decenomy.net/coreapi/v1/coins/DOGECASH?expand=overview | jq -r ".response.versions.wallet")

	  WALLETVERSION=$(~/bin/${NAME}-cli_$DOGECASHNAME.sh getinfo | grep -i \"version\")
	  WALLETVERSION=$(echo $WALLETVERSION | tr , " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr '"' " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr 'version : ' " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr -d ' ' )

	  if ! [ "$WALLETVERSION" == "5040100" ]; then
	     echo "!!!Your wallet $DOGECASHNAME is OUTDATED!!!"
	  fi

	  echo "LASTBLOCK="$LASTBLOCK
	  echo "GETBLOCKHASH="$GETBLOCKHASH
	  echo "BLOCKHASHCOINEXPLORERDOGECASH="$BLOCKHASHCOINEXPLORERDOGECASH
	  echo "WALLETVERSION="$WALLETVERSION

	  if [ "$GETBLOCKHASH" == "$BLOCKHASHCOINEXPLORERDOGECASH" ]; then
		echo "Wallet $FILE is SYNCED!"
	  else
		if [ "$BLOCKHASHCOINEXPLORERDOGECASH" == "Too" ]; then
		   echo "COINEXPLORERDOGECASH Too many requests"
		else
		   echo "Wallet $FILE is NOT SYNCED!"
		fi
	  fi
  fi
done
