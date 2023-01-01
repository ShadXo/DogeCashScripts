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
  #ALIASSTARTPOS=$(echo $FILE | grep -b -o _)
  #ALIASLENGTH=$(echo $FILE | grep -b -o .sh)./mon
  # echo ${ALIASSTARTPOS:0:2}
  #ALIASSTARTPOS_1=$(echo ${ALIASSTARTPOS:0:2})
  #ALIASSTARTPOS_1=$[ALIASSTARTPOS_1 + 1]
  #NODEALIAS=$(echo ${FILE:ALIASSTARTPOS_1:${ALIASLENGTH:0:2}-ALIASSTARTPOS_1})
  NODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
  NODECONFPATH=$(echo "$HOME/.${NAME}_$NODEALIAS")
  # echo $ALIASSTARTPOS_1
  # echo ${ALIASLENGTH:0:2}
  echo CONF DIR: $NODECONFPATH

  if [ ! -d $NODECONFPATH ]; then
	echo "Directory $NODECONFPATH not found!"
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

	if [ "$BLOCKHASHCOINEXPLORER" == "Too" ]; then
	   echo "COINEXPLORER Too many requests"
	   break
	fi

	# Wallet is not synced
	echo $DATE" Wallet $NODEALIAS is NOT SYNCED!"
	#
	# echo $LASTBLOCKCOINEXPLORERDOGECASH
	#break

	if [ -z "$NODEPID" ]; then
	   echo ""
	else
		#STOP
		~/bin/${NAME}-cli_$NODEALIAS.sh stop

		if [[ "$COUNTER" -gt 1 ]]; then
		  kill -9 $NODEPID
		fi
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
	  # wget http://107.191.46.178/DOGECASH/bootstrap/bootstrap.zip -O bootstrap.zip
	  # wget http://194.135.84.214/DOGECASH/bootstrap/bootstrap.zip -O bootstrap.zip
	  # wget http://167.86.97.235/DOGECASH/bootstrap/bootstrap.zip -O bootstrap.zip
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

	COUNTER=$[COUNTER + 1]
	echo COUNTER: $COUNTER
	if [[ "$COUNTER" -gt 9 ]]; then
	  break
	fi
  done
done
