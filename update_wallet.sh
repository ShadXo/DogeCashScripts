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

# GET CONFIGURATION
#declare -r SCRIPTPATH=$( cd $(dirname ${BASH_SOURCE[0]}) > /dev/null; pwd -P )
#SETUP_CONF_FILE="${SCRIPTPATH}/coins/${NAME}/${NAME}.env"
SETUP_CONF_FILE="./coins/${NAME}/${NAME}.env"
#if [ `wget --spider -q https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/coins/${NAME}/${NAME}.env` ]; then
mkdir -p ./coins/${NAME}
wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/coins/${NAME}/${NAME}.env -O $SETUP_CONF_FILE > /dev/null 2>&1
chmod 777 $SETUP_CONF_FILE &> /dev/null
#dos2unix $SETUP_CONF_FILE > /dev/null 2>&1
#fi

if [ -f ${SETUP_CONF_FILE} ] && [ -s ${SETUP_CONF_FILE} ]; then
  echo "Using setup env file: ${SETUP_CONF_FILE}"
  source "${SETUP_CONF_FILE}"
else
  echo "No setup env file found, create one at the following location: ./coins/${NAME}/${NAME}.env"
  exit 1
fi

## MAIN
echo
echo "${NAME} - Masternode updater"
echo ""
echo "Welcome to the ${NAME} Masternode update script."
echo "Wallet v${WALLETVERSION}"
echo

for FILE in ~/bin/${NAME}-cli*.sh; do
  sh $FILE stop
  sleep 2
done

cd ~
sudo killall -9 ${NAME}d
sudo rm -rdf /usr/local/bin/${NAME}*

# Create Temp folder
mkdir -p $CONF_DIR_TMP

if [ $PARAMS == "YES" ]; then
  mkdir -p $PARAMS_PATH
fi

cd $CONF_DIR_TMP
echo "Downloading wallet"
if [[ $WALLETURL == *.tar.gz ]]; then
  wget ${WALLETURL} -O wallet.tar.gz
  WGET=$?
elif [[ $WALLETURL == *.zip ]]; then
  wget ${WALLETURL} -O wallet.zip
  WGET=$?
fi

if [ $WGET -ne 0 ]; then
  echo -e "${RED}Wallet download failed, check the WALLETURL.${NC}"
  rm -rfd $CONF_DIR_TMP
  exit 1
fi

if [[ $WALLETURL == *.tar.gz ]]; then
  #tar -xvzf ${WALLETDL} #-C ${WALLETDLFOLDER}
  tar -xvzf wallet.tar.gz
elif [[ $WALLETURL == *.zip ]]; then
  #unzip ${WALLETDL} #-d ${WALLETDLFOLDER}
  unzip wallet.zip
fi

if [ $WALLETDLFOLDER ]; then
  cd ${WALLETDLFOLDER}
fi

chmod 775 *
mv */* . &> /dev/null # Some coins have files in subfolders
mv ${NAME}d ${NAME}-cli /usr/local/bin # previous /usr/bin should be /usr/local/bin

if [ $PARAMS == "YES" ]; then
  #mv ./share/${NAME}/*.params $PARAMS_PATH
  mv */*.params $PARAMS_PATH
fi

# Remove Temp folder
rm -rfd $CONF_DIR_TMP

for FILE in ~/bin/${NAME}d*.sh; do
  echo "FILE: $FILE"
  sh $FILE
  sleep 2
done

echo "Your masternode wallets are now updated!"
