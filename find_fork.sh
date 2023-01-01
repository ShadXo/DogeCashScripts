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

			#BLOCKHASHEXPLORER=$(curl -s4 https://api2.dogecash.org/height/$BLOCK | jq -r ".result.hash")
      BLOCKHASHEXPLORER=$(curl -s4 https://dogec.flitswallet.app/api/block/$BLOCK | jq -r ".hash")
			if [ -z "$BLOCKHASHEXPLORER" ]; then
			  break 2
			fi
      if [ "$BLOCKHASHEXPLORER" == null ]; then
        echo "NO FORK FOUND"
			  break 2
			fi

      #BLOCKHASHWALLET=$(~/bin/${NAME}-cli_$WALLET.sh getblockhash $BLOCK)
      BLOCKHASHWALLET=$($FILE getblockhash $BLOCK)
      if [ -z "$BLOCKHASHWALLET" ]; then
			  break 2
			fi

			echo "BLOCKHASHEXPLORER=$BLOCKHASHEXPLORER"
      echo "BLOCKHASHWALLET=$BLOCKHASHWALLET"
		done

		if [ "$BLOCKHASHWALLET" != "$BLOCKHASHEXPLORER" ]; then
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
