#!/bin/bash

NAME="dogecash"
PARAM1=$*

sudo apt-get install -y jq > /dev/null 2>&1

if [ -z "$PARAM1" ]; then
  PARAM1="*"
else
  PARAM1=${PARAM1,,}
fi

for FILE in $(ls ~/bin/${NAME}d_$PARAM1.sh | sort -V); do
  echo "****************************************************************************"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE: $DATE"
  echo "FILE: $FILE"
  #cat $FILE
  #ALIASSTARTPOS=$(echo $FILE | grep -b -o _)
  #ALIASLENGTH=$(echo $FILE | grep -b -o .sh)
  # echo ${ALIASSTARTPOS:0:2}
  #ALIASSTARTPOS_1=$(echo ${ALIASSTARTPOS:0:2})
  #ALIASSTARTPOS_1=$[ALIASSTARTPOS_1 + 1]
  #NODEALIAS=$(echo ${FILE:ALIASSTARTPOS_1:${ALIASLENGTH:0:2}-ALIASSTARTPOS_1})
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFPATH=$(echo "$HOME/.${NAME}_$NODEALIAS")
  # echo $ALIASSTARTPOS_1
  # echo ${ALIASLENGTH:0:2}
  echo CONF FOLDER: $NODECONFPATH

  for (( ; ; ))
  do
    sleep 2

	NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	echo "NODEPID="$NODEPID

	if [ -z "$NODEPID" ]; then
	  echo "Node $NODEALIAS is STOPPED can't check if synced!"
	  break
	fi

	LASTBLOCK=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockcount)
	GETBLOCKHASH=$(~/bin/${NAME}-cli_$NODEALIAS.sh getblockhash $LASTBLOCK)

	echo "LASTBLOCK="$LASTBLOCK
	echo "GETBLOCKHASH="$GETBLOCKHASH

  #BLOCKHASHCOINEXPLORER=$(curl -s4 https://explorer.dogec.io/api/blocks | jq -r ".backend.bestblockhash")
  BLOCKHASHCOINEXPLORER=$(curl -s4 https://dogec.flitswallet.app/api/blocks | jq -r ".backend.bestBlockHash")
  #BLOCKHASHCOINEXPLORER=$(curl -s4 https://api2.dogecash.org/info | jq -r ".result.bestblockhash")

	echo "LASTBLOCK="$LASTBLOCK
	echo "GETBLOCKHASH="$GETBLOCKHASH
	echo "BLOCKHASHCOINEXPLORER="$BLOCKHASHCOINEXPLORER


	echo "GETBLOCKHASH="$GETBLOCKHASH
	echo "BLOCKHASHCOINEXPLORER="$BLOCKHASHCOINEXPLORER
	if [ "$GETBLOCKHASH" == "$BLOCKHASHCOINEXPLORER" ]; then
		echo $DATE" Wallet $NODEALIAS is SYNCED!"
		break
	else
	    if [ "$BLOCKHASHCOINEXPLORER" == "Too" ]; then
		   echo "COINEXPLORER Too many requests"
		   break
		fi

		# Wallet is not synced
		echo $DATE" Wallet $NODEALIAS is NOT SYNCED!"
		#
		# echo $LASTBLOCKCOINEXPLORERDOGECASH
		#break
		#STOP
		~/bin/${NAME}-cli_$NODEALIAS.sh stop

		if [[ "$COUNTER" -gt 1 ]]; then
		  kill -9 $NODEPID
		fi

		sleep 2 # wait 2 seconds
		NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
		echo "NODEPID="$NODEPID

		if [ -z "$NODEPID" ]; then
		  echo "Node $NODEALIAS is STOPPED"

		  cd $NODECONFPATH
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

		  NODEPID=`ps -ef | grep -i -w ${NAME}_$NODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
		  echo "NODEPID="$NODEPID

		  if [ -z "$NODEPID" ]; then
			echo "Node $NODEALIAS still not running!"
		  fi

		  break
		else
		  echo "Node $NODEALIAS still running!"
		fi
	fi

	COUNTER=$[COUNTER + 1]
	echo COUNTER: $COUNTER
	if [[ "$COUNTER" -gt 9 ]]; then
	  break
	fi
  done
done
