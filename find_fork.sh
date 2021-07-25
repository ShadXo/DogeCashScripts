#/bin/bash

NAME="dogecash"
WALLET=$1
LASTBLOCK=$2
INCREMENT=$3

for (( ; ; ))
do

	for (( ; ; ))
	do
		echo "LASTBLOCK=$LASTBLOCK"

		for filename in /root/bin/${NAME}-cli*.sh; do
			echo $filename
			GETBLOCKHASHWALLET=$(~/bin/${NAME}-cli_$WALLET.sh getblockhash $LASTBLOCK)
			GETBLOCKHASH=$($filename getblockhash $LASTBLOCK)

			if [ -z "$GETBLOCKHASHWALLET" ]; then
			  break
			fi

			if [ -z "$GETBLOCKHASH" ]; then
			  break
			fi

			echo "GETBLOCKHASHWALLET=$GETBLOCKHASHWALLET"
			echo "GETBLOCKHASH=$GETBLOCKHASH"
		done

		if [ -z "$GETBLOCKHASHWALLET" ]; then
		 break
		fi

		if [ -z "$GETBLOCKHASH" ]; then
		  break
		fi

		if [ "$GETBLOCKHASH" != "$GETBLOCKHASHWALLET" ]; then
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
