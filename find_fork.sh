#/bin/bash

NAME="dogecash"
WALLET=$1
BLOCK=$2
#INCREMENT=$3
INCREMENT=1

if [ -z "$WALLET" ]; then
  echo "Need to specify node alias!"
  exit -1
fi
if [ -z "$BLOCK" ]; then
  echo "Need to specify a starting block!"
  exit -1
fi

for (( ; ; ))
do

	for (( ; ; ))
	do
		echo "Starting from $BLOCK"

		for FILE in $(ls ~/bin/${NAME}-cli_$WALLET.sh | sort -V); do
      echo "*******************************************"
			echo $FILE
			#BLOCKHASHEXPLORER=$(~/bin/${NAME}-cli_$WALLET.sh getblockhash $BLOCK)
			BLOCKHASHEXPLORER=$(curl -s4 https://dogec.flitswallet.app/api/block/$BLOCK | jq -r ".hash")
			#BLOCKHASHEXPLORER=$(curl -s4 https://api2.dogecash.org/height/$BLOCK | jq -r ".result.hash")
			BLOCKHASHWALLET=$($FILE getblockhash $BLOCK)

			if [ -z "$BLOCKHASHEXPLORER" ]; then
			  break 2
			fi

			if [ -z "$BLOCKHASHWALLET" ]; then
			  break 2
			fi

			echo "BLOCKHASHEXPLORER=$BLOCKHASHEXPLORER"
			echo "BLOCKHASHWALLET=$BLOCKHASHWALLET"
		done

		if [ "$BLOCKHASHWALLET" != "$BLOCKHASHEXPLORER" ]; then
		  echo "FORK ON $BLOCK !!!!"
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
