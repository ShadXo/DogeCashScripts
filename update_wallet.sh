echo
echo "DogeCash - Masternode updater"
echo ""
echo "Welcome to the DogeCash Masternode update script."
echo "Wallet v5.4.4"
echo

NAME="dogecash"
WALLETVERSION="5.4.4"
WALLETDLFOLDER="${NAME}-${WALLETVERSION}"
WALLETDL="${WALLETDLFOLDER}-x86_64-linux-gnu.tar.gz"
URL="https://github.com/dogecash/dogecash/releases/download/${WALLETVERSION}/${WALLETDL}"
CONF_DIR_TMP=~/"${NAME}_tmp"


for filename in ~/bin/${NAME}-cli*.sh; do
  sh $filename stop
  sleep 1
done

cd ~
sudo killall -9 ${NAME}d
sudo rm -rdf /usr/bin/${NAME}*
cd

mkdir -p $CONF_DIR_TMP
mkdir -p ~/.dogecash-params

cd $CONF_DIR_TMP
wget ${URL}
sudo chmod 775 ${WALLETDL}
tar -xvzf ${WALLETDL}
#unzip ${WALLETDL} -d ${WALLETDLFOLDER}
#rm -f ${WALLETDL}

cd ./${WALLETDLFOLDER}
sudo chmod 775 *
sudo mv ./bin/${NAME}* /usr/bin
sudo mv ./share/dogecash/*.params ~/.dogecash-params

cd ~
rm -rfd $CONF_DIR_TMP

for filename in ~/bin/${NAME}d*.sh; do
  echo $filename
  sh $filename
  sleep 1
done

echo "Your masternode wallets are now updated!"
