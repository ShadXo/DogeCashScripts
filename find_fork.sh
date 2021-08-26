#/bin/bash

NAME="dogecash"
WALLET=$1
LASTBLOCK=$2
#INCREMENT=$3
INCREMENT=1

for (( ; ; ))
do

	for (( ; ; ))
	do
		echo "LASTBLOCK=$LASTBLOCK"

		for filename in ~/bin/${NAME}-cli_$WALLET.sh; do
			echo $filename
			#GETBLOCKHASHEXPLORER=$(~/bin/${NAME}-cli_$WALLET.sh getblockhash $LASTBLOCK)
			#GETBLOCKHASHEXPLORER=$(curl -s4 https://dogec.flitswallet.app/api/block/$LASTBLOCK | jq -r ".hash")
			GETBLOCKHASHEXPLORER=$(curl -s4 https://api2.dogecash.org/height/$LASTBLOCK | jq -r ".result.hash")
			GETBLOCKHASHWALLET=$($filename getblockhash $LASTBLOCK)

			if [ -z "$GETBLOCKHASHEXPLORER" ]; then
			  break
			fi

			if [ -z "$GETBLOCKHASHWALLET" ]; then
			  break
			fi

			echo "GETBLOCKHASHEXPLORER=$GETBLOCKHASHEXPLORER"
			echo "GETBLOCKHASHWALLET=$GETBLOCKHASHWALLET"
		done

		if [ -z "$GETBLOCKHASHEXPLORER" ]; then
		 break
		fi

		if [ -z "$GETBLOCKHASHWALLET" ]; then
		  break
		fi

		if [ "$GETBLOCKHASHWALLET" != "$GETBLOCKHASHEXPLORER" ]; then
		  echo "FORK ON $LASTBLOCK !!!!"
		  break
		fi

		LASTBLOCK=$[LASTBLOCK + $INCREMENT]
	done

	LASTBLOCK=$[LASTBLOCK - $INCREMENT]
	INCREMENT=$[INCREMENT / 10]

    if [[ "$INCREMENT" -eq 0 ]]; then
	  break
	fi

    if [[ "$INCREMENT" -lt 1 ]]; then
	  break
	fi
done
