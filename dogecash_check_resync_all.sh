#!/bin/bash

NAME="dogecash"
PARAM1=$*

sudo apt-get install -y jq > /dev/null 2>&1

if [ -z "$PARAM1" ]; then
  PARAM1="*"
else
  PARAM1=${PARAM1,,}
fi

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  echo "****************************************************************************"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE="$DATE
  echo FILE: " $FILE"
  #cat $FILE
  DOGECASHSTARTPOS=$(echo $FILE | grep -b -o _)
  DOGECASHLENGTH=$(echo $FILE | grep -b -o .sh)
  # echo ${DOGECASHSTARTPOS:0:2}
  #DOGECASHSTARTPOS_1=$(echo ${DOGECASHSTARTPOS:0:2})
  #DOGECASHSTARTPOS_1=$[DOGECASHSTARTPOS_1 + 1]
  #DOGECASHNAME=$(echo ${FILE:DOGECASHSTARTPOS_1:${DOGECASHLENGTH:0:2}-DOGECASHSTARTPOS_1})
  DOGECASHNAME=$(echo $FILE | awk -F'[_.]' '{print $2}')
  DOGECASHCONFPATH=$(echo "$HOME/.${NAME}_$DOGECASHNAME")
  # echo $DOGECASHSTARTPOS_1
  # echo ${DOGECASHLENGTH:0:2}
  echo CONF FOLDER: $DOGECASHCONFPATH

  for (( ; ; ))
  do
    sleep 2

	DOGECASHPID=`ps -ef | grep -i _$DOGECASHNAME | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	echo "DOGECASHPID="$DOGECASHPID

	if [ -z "$DOGECASHPID" ]; then
	  echo "DOGECASH $DOGECASHNAME is STOPPED can't check if synced!"
	  break
	fi

	LASTBLOCK=$(~/bin/${NAME}-cli_$DOGECASHNAME.sh getblockcount)
	GETBLOCKHASH=$(~/bin/${NAME}-cli_$DOGECASHNAME.sh getblockhash $LASTBLOCK)

	echo "LASTBLOCK="$LASTBLOCK
	echo "GETBLOCKHASH="$GETBLOCKHASH

  #BLOCKHASHCOINEXPLORERDOGECASH=$(curl -s4 https://explorer.dogec.io/api/blocks | jq -r ".backend.bestblockhash")
  BLOCKHASHCOINEXPLORERDOGECASH=$(curl -s4 https://dogec.flitswallet.app/api/blocks | jq -r ".backend.bestBlockHash")

	echo "LASTBLOCK="$LASTBLOCK
	echo "GETBLOCKHASH="$GETBLOCKHASH
	echo "BLOCKHASHCOINEXPLORERDOGECASH="$BLOCKHASHCOINEXPLORERDOGECASH


	echo "GETBLOCKHASH="$GETBLOCKHASH
	echo "BLOCKHASHCOINEXPLORERDOGECASH="$BLOCKHASHCOINEXPLORERDOGECASH
	if [ "$GETBLOCKHASH" == "$BLOCKHASHCOINEXPLORERDOGECASH" ]; then
		echo $DATE" Wallet $DOGECASHNAME is SYNCED!"
		break
	else
	    if [ "$BLOCKHASHCOINEXPLORERDOGECASH" == "Too" ]; then
		   echo "COINEXPLORERDOGECASH Too many requests"
		   break
		fi

		# Wallet is not synced
		echo $DATE" Wallet $DOGECASHNAME is NOT SYNCED!"
		#
		# echo $LASTBLOCKCOINEXPLORERDOGECASH
		#break
		#STOP
		~/bin/${NAME}-cli_$DOGECASHNAME.sh stop

		if [[ "$COUNTER" -gt 1 ]]; then
		  kill -9 $DOGECASHPID
		fi

		sleep 2 # wait 2 seconds
		DOGECASHPID=`ps -ef | grep -i _$DOGECASHNAME | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
		echo "DOGECASHPID="$DOGECASHPID

		if [ -z "$DOGECASHPID" ]; then
		  echo "DOGECASH $DOGECASHNAME is STOPPED"

		  cd $DOGECASHCONFPATH
		  echo CURRENT CONF FOLDER: $PWD
		  echo "Copy BLOCKCHAIN without conf files"
		  # wget http://blockchain.DOGECASHey.vision/ -O bootstrap.zip
		  #wget http://107.191.46.178/DOGECASH/bootstrap/bootstrap.zip -O bootstrap.zip
		  #wget http://194.135.84.214/DOGECASH/bootstrap/bootstrap.zip -O bootstrap.zip
		  #wget http://167.86.97.235/DOGECASH/bootstrap/bootstrap.zip -O bootstrap.zip
      wget https://www.dropbox.com/s/s4vy92sczk9c10s/blocks_n_chains.tar.gz -O blocks_n_chains.tar.gz
		  # rm -R peers.dat
		  rm -R ./database
		  rm -R ./blocks
		  rm -R ./sporks
		  rm -R ./chainstate
		  #unzip  bootstrap.zip
      tar -xvzf blocks_n_chains.tar.gz
		  $FILE
		  sleep 3 # wait 3 seconds

		  DOGECASHPID=`ps -ef | grep -i _$DOGECASHNAME | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
		  echo "DOGECASHPID="$DOGECASHPID

		  if [ -z "$DOGECASHPID" ]; then
			echo "DogeCash $DOGECASHNAME still not running!"
		  fi

		  break
		else
		  echo "DogeCash $DOGECASHNAME still running!"
		fi
	fi

	COUNTER=$[COUNTER + 1]
	echo COUNTER: $COUNTER
	if [[ "$COUNTER" -gt 9 ]]; then
	  break
	fi
  done
done
